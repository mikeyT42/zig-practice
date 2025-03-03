const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();
const stdin = std.io.getStdIn().reader();

const LoopControl = enum {
    again,
    stop,
};

const Point = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    try clear();
    _ = try stdout.write(
        \\------------------------------------------------------------------------------------------
        \\                          Welcome to the Palindrome Checker
        \\------------------------------------------------------------------------------------------
        \\
        \\
    );

    var loop_control = LoopControl.again;
    while (loop_control == LoopControl.again) {
        loop_control = try inputLoop();
    }

    _ = try stdout.write(
        \\
        \\------------------------------------------------------------------------------------------
        \\                              Dhank you, come again. 
        \\------------------------------------------------------------------------------------------
        \\
    );
}

// -------------------------------------------------------------------------------------------------
fn clear() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{"clear"},
    });
    defer {
        allocator.free(result.stdout);
        allocator.free(result.stderr);
    }

    _ = try stdout.write(result.stdout);
}

// -------------------------------------------------------------------------------------------------
fn inputLoop() !LoopControl {
    const buf_len: u8 = comptime 32;
    const sentinel: u8 = comptime '\n';

    _ = try stdout.write("Please input 2 integers, an x and y value, for a point in space.\n");

    var input_buf: [buf_len]u8 = undefined;
    const line = try stdin.readUntilDelimiterOrEof(&input_buf, sentinel);
    const input = line orelse "";
    if (input.len == 0)
        return LoopControl.stop;

    const parsed_tuple = try parseInput(input);
    if (parsed_tuple == null) {
        _ = try stdout.write("You did not enter 2 valid integers to create a point. Try again.\n");
        return LoopControl.again;
    }
    const x, const y = parsed_tuple.?;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const point = createPoint(allocator, x, y) catch return LoopControl.again;
    const point_string = toString(allocator, point) catch return LoopControl.again;

    _ = try stdout.print("\n{s}\n\n", .{point_string});

    return LoopControl.again;
}

// -------------------------------------------------------------------------------------------------
test parseInput {
    try std.testing.expectEqual(.{ 1, 2 }, parseInput("1 2"));
    try std.testing.expectEqual(.{ 1, 2 }, parseInput("1  2"));
    try std.testing.expectEqual(.{ 1, 2 }, parseInput(" 1  2 "));
    try std.testing.expectEqual(null, parseInput(""));
    try std.testing.expectEqual(null, parseInput("1 2 3"));
    try std.testing.expectError(std.fmt.ParseIntError.InvalidCharacter, parseInput("1 ;kladsf"));
}

fn parseInput(input: []const u8) !?struct { i32, i32 } {
    var split_input = std.mem.splitScalar(u8, input, ' ');
    var point: [2]i32 = undefined;
    var number_of_ints: usize = 0;
    while (split_input.next()) |split| {
        if (split.len == 0)
            continue;

        if (number_of_ints == 2)
            return null;

        point[number_of_ints] = try std.fmt.parseInt(i32, split, 10);
        number_of_ints += 1;
    }

    if (number_of_ints < 2) {
        return null;
    } else {
        return .{ point[0], point[1] };
    }
}

// -------------------------------------------------------------------------------------------------
test "createPoint successfully" {
    const allocator = std.testing.allocator;
    const result = try createPoint(allocator, 1, 2);
    defer allocator.destroy(result);
    try std.testing.expect(result.*.x == 1 and result.*.y == 2);
}

test "createPoint failure" {
    const failing_allocator = std.testing.failing_allocator;
    const result = createPoint(failing_allocator, 1, 2);
    try std.testing.expectError(error.OutOfMemory, result);
}

/// Caller owns returned Point memory.
fn createPoint(allocator: std.mem.Allocator, x: i32, y: i32) !*Point {
    const point = allocator.create(Point) catch |err| {
        stderr.print("Could not create a Point.\n{}\n", .{err}) catch unreachable;
        return err;
    };

    point.*.x = x;
    point.*.y = y;

    return point;
}

// -------------------------------------------------------------------------------------------------
test "toString successfully" {
    const allocator = std.testing.allocator;
    const point = try toString(allocator, &Point{ .x = 1, .y = 2 });
    defer allocator.free(point);
    try std.testing.expectEqualStrings(
        \\point {
        \\    x = 1
        \\    y = 2
        \\}
        \\
    , point);
}

test "toString unsuccessfully" {
    const allocator = std.testing.failing_allocator;
    const result = toString(allocator, &Point{ .x = 1, .y = 2 });
    try std.testing.expectError(error.OutOfMemory, result);
}

/// Caller owns returned string memory.
fn toString(allocator: std.mem.Allocator, point: *const Point) ![]u8 {
    return std.fmt.allocPrint(allocator,
        \\point {{
        \\{c: >5} = {d}
        \\{c: >5} = {d}
        \\}}
        \\
    , .{ 'x', point.*.x, 'y', point.*.y }) catch |err| {
        stderr.print("Could not create a point string.\n{}\n", .{err}) catch unreachable;
        return err;
    };
}
