const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const max_items = 10;

const Sums = struct {
    positive: f32 = 0.0,
    negatice: f32 = 0.0,
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
    ok: []f16,
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
        loop_control = try input_loop();
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
fn input_loop() !LoopControl {
    const buf_size = comptime 250;
    const sentinel = comptime '\n';

    var input_buf: [buf_size]u8 = undefined;

    _ = try stdout.print(
        \\Please input up to {d} floating point or integer numbers. Seperate them with spaces.
        \\Simply enter a newline character to exit.
        \\
        \\
    , .{max_items});
    const line = try stdin.readUntilDelimiterOrEof(&input_buf, sentinel);

    const numbers = switch(validate(line)) {
        InputValidation.no_input => {
            _ = try stdout.write("Sorry, but you didn't enter any input. Please try again.\n\n");
            return LoopControl.again;
        },
        InputValidation.too_many => {
            _ = try stdout.print("You input too many numbers, please only input up to {d}.\n\n", .{max_items});
            return LoopControl.again;
        },
        InputValidation.input_error => |err| {
            _ = try stdout.print("You did not input valid input [{s}]\nerror:\n{}\n\n", .{ line.?, err });
            return LoopControl.again;
        },
        InputValidation.ok => |parsed_numbers| parsed_numbers,
    };

    var sums: Sums = .{};
    var counts: Counts = .{};
    var averages: Averages = .{};

    return LoopControl.again;
}

// -------------------------------------------------------------------------------------------------
fn validate(optional_input: ?[]const u8) InputValidation {
    const input: []const u8 = optional_input orelse return InputValidation.no_input;
    if (input.len == 0)
        return InputValidation.no_input;
    var nums = std.mem.splitScalar(u8, input, ' ');
    if (nums.peek() == null)
        return InputValidation.no_input;

    var parsed_nums: [max_items]f16 = undefined;
    for (nums.next(), 0..) |num, i| {
        if (i == max_items)
            return InputValidation.too_many;

        parsed_nums[i] = std.fmt.parseFloat(f16, num) catch |err| return InputValidation{ .input_error = err };
    }

    return InputValidation{ .ok = parsed_nums };
}

// -------------------------------------------------------------------------------------------------
fn sum_and_count(numbers: []const f16, sums: *Sums, counts: *Counts) void {
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
fn average(sums: *const Sums, counts: *const Counts, averages: *Averages) void {
    if(counts.*.positive == 0) {
        averages.*.positive = 0;
    } else {
        averages.*.positive = sums.*.positive / counts.*.positive;
    }

    if (counts.*.negative == 0) {
        averages.*.negative = 0;
    } else {
        averages.*.negative = sums.*.negative / counts.*.negative;
    }

    if (sums.*.overall == 0 or counts.*.overall == 0) {
        averages.*.overall = 0;
    } else {
        averages.*.overall = sums.*.overall / counts.*.overall;
    }
}
