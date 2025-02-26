const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const LoopControl = enum {
    again,
    stop,
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

    const x: ?i32, const y: ?i32 = try parseInput(input);
    _ = x;
    _ = y;
}

// -------------------------------------------------------------------------------------------------
test parseInput {
    try std.testing.expectEqual(.{ 1, 2 }, parseInput("1 2"));
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

    return .{ point[0], point[1] };
}
