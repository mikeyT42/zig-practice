const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const Sums = struct {
    positive: f32 = 0.0,
    negative: f32 = 0.0,
    overall: f32 = 0.0,
};

const Counts = struct {
    positive: u16 = 0,
    negative: u16 = 0,
    overall: u16 = 0,
};

const Averages = struct {
    positive: f32 = 0.0,
    negative: f32 = 0.0,
    overall: f32 = 0.0,
};

const InputValidation = union(enum) {
    ok: struct { []f16, usize },
    no_input: void,
    too_many: void,
    input_error: std.fmt.ParseFloatError,
};

const LoopControl = enum {
    again,
    stop,
};

pub fn main() !void {
    try clear();
    _ = try stdout.write(
        \\------------------------------------------------------------------------------------------
        \\                                          Welcome
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
        \\                                          Goodbye 
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
    const buf_size = comptime 250;
    const sentinel = comptime '\n';
    const max_items = comptime 10;

    var input_buf: [buf_size]u8 = undefined;

    _ = try stdout.print(
        \\Please input up to {d} floating point or integer numbers. Seperate them with spaces.
        \\Simply enter a newline character to exit.
        \\
        \\
    , .{max_items});
    const line = try stdin.readUntilDelimiterOrEof(&input_buf, sentinel);

    var numbers_buf: [max_items]f16 = undefined;
    const numbers: []f16, const len: usize = switch (validate(line, &numbers_buf)) {
        InputValidation.no_input => {
            return LoopControl.stop;
        },
        InputValidation.too_many => {
            _ = try stdout.print(
                "You input too many numbers, please only input up to {d}.\n\n",
                .{max_items},
            );
            return LoopControl.again;
        },
        InputValidation.input_error => |err| {
            _ = try stdout.print(
                "You did not input valid input [{s}]\nerror:\n{}\n\n",
                .{ line.?, err },
            );
            return LoopControl.again;
        },
        InputValidation.ok => |parsed_tuple| parsed_tuple,
    };

    var sums: Sums = .{};
    var counts: Counts = .{};
    var averages: Averages = .{};
    sumAndCount(numbers[0..len], &sums, &counts);
    average(&sums, &counts, &averages);
    _ = try printTable(&sums, &counts, &averages);

    return LoopControl.again;
}

// -------------------------------------------------------------------------------------------------
test validate {
    // No Input
    const len = comptime 10;
    _ = try std.testing.expectEqual(
        InputValidation.no_input,
        validate(null, @constCast(&[_]f16{0} ** len)),
    );
    _ = try std.testing.expectEqual(
        InputValidation.no_input,
        validate("", @constCast(&[_]f16{0} ** len)),
    );
    _ = try std.testing.expectEqual(
        InputValidation.no_input,
        validate(" ", @constCast(&[_]f16{0} ** len)),
    );
    // Too Many
    _ = try std.testing.expectEqual(
        InputValidation.too_many,
        validate("1 2", &[0]f16{}),
    );
    // Input Error
    _ = try std.testing.expectEqualDeep(
        InputValidation{ .input_error = error.InvalidCharacter },
        validate("nvim", @constCast(&[1]f16{0})),
    );
    // Ok
    var parsed: [2]f16 = undefined;
    _ = try std.testing.expectEqualDeep(
        InputValidation{ .ok = .{ @constCast(&[_]f16{ 1, 2 }), 2 } },
        validate("  1  2  ", &parsed),
    );
    _ = try std.testing.expectEqualDeep(
        InputValidation{ .ok = .{ @constCast(&[_]f16{ 3, 4 }), 2 } },
        validate("3 4", &parsed),
    );
}

fn validate(optional_input: ?[]const u8, parsed_nums: []f16) InputValidation {
    const input: []const u8 = optional_input orelse return InputValidation.no_input;
    if (input.len == 0)
        return InputValidation.no_input;

    const trimmed_input = std.mem.trim(u8, input, &std.ascii.whitespace);
    var nums = std.mem.splitScalar(u8, trimmed_input, ' ');
    const peeked = nums.peek();
    if (peeked == null or std.mem.eql(u8, peeked.?, ""))
        return InputValidation.no_input;

    var len: u8 = 0;
    while (nums.next()) |num| {
        if (len == parsed_nums.len)
            return InputValidation.too_many;
        if (std.mem.eql(u8, num, ""))
            continue;

        parsed_nums[len] = std.fmt.parseFloat(f16, num) catch |err|
            return InputValidation{ .input_error = err };
        len += 1;
    }

    return InputValidation{ .ok = .{ parsed_nums, len } };
}

// -------------------------------------------------------------------------------------------------
test sumAndCount {
    var sums: Sums = .{};
    var counts: Counts = .{};
    const numbers = [_]f16{ 5.0, -5.0, -5.0, 5.0 };
    sumAndCount(&numbers, &sums, &counts);
    _ = try std.testing.expect(sums.positive == 10);
    _ = try std.testing.expect(sums.negative == -10);
    _ = try std.testing.expect(sums.overall == 0);
    _ = try std.testing.expect(counts.positive == 2);
    _ = try std.testing.expect(counts.negative == 2);
    _ = try std.testing.expect(counts.overall == 4);
}

fn sumAndCount(numbers: []const f16, sums: *Sums, counts: *Counts) void {
    for (numbers) |number| {
        if (number >= 0) {
            sums.*.positive += number;
            counts.*.positive += 1;
        } else {
            sums.*.negative += number;
            counts.*.negative += 1;
        }
        sums.*.overall += number;
        counts.*.overall += 1;
    }
}

// -------------------------------------------------------------------------------------------------
test average {
    const sums: Sums = .{ .positive = 10, .negative = -10, .overall = 0 };
    const counts: Counts = .{ .positive = 2, .negative = 2, .overall = 4 };
    var averages: Averages = .{};
    average(&sums, &counts, &averages);
    _ = try std.testing.expect(averages.positive == 5);
    _ = try std.testing.expect(averages.negative == -5);
    _ = try std.testing.expect(averages.overall == 0);
}

fn average(sums: *const Sums, counts: *const Counts, averages: *Averages) void {
    if (counts.*.positive == 0) {
        averages.*.positive = 0;
    } else {
        averages.*.positive = @as(f32, sums.*.positive) /
            @as(f32, @floatFromInt(counts.*.positive));
    }

    if (counts.*.negative == 0) {
        averages.*.negative = 0;
    } else {
        averages.*.negative = @as(f32, sums.*.negative) /
            @as(f32, @floatFromInt(counts.*.negative));
    }

    if (sums.*.overall == 0 or counts.*.overall == 0) {
        averages.*.overall = 0;
    } else {
        averages.*.overall = @as(f32, sums.*.overall) /
            @as(f32, @floatFromInt(counts.*.overall));
    }
}

// -------------------------------------------------------------------------------------------------
fn printTable(sums: *const Sums, counts: *const Counts, averages: *const Averages) !void {
    _ = try stdout.print(
        \\  Statistics:
        \\{s: >18}{s: >16}{s: >14}
        \\Positive:{d: >9}{d: >16.3}{d: >14.3}
        \\Negative:{d: >9}{d: >16.3}{d: >14.3}
        \\Overall:{d: >10}{d: >16.3}{d: >14.3}
        \\
        \\
    , .{
        "Number:",
        "Total:",
        "Average:",
        counts.*.positive,
        sums.*.positive,
        averages.*.positive,
        counts.*.negative,
        sums.*.negative,
        averages.*.negative,
        counts.*.overall,
        sums.*.overall,
        averages.*.overall,
    });
}
