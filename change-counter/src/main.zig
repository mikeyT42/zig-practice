const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const LoopControl = enum {
    again,
    stop,
};

const InputValidation = union(enum) {
    ok: f16,
    out_of_range: void,
    no_input: void,
    input_error: std.fmt.ParseFloatError,
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
    const delimiter = comptime '\n';
    const sentinel = comptime -1;
    var input_buf: [buf_size]u8 = undefined;

    _ = try stdout.write(
        \\Enter the amount you spent to two decimal places: the input must be between 0 and 1: -1 is
        \\to exit.
        \\
    );
    const line = try stdin.readUntilDelimiterOrEof(&input_buf, delimiter);

    const input_cost: f16 = switch (validate(line)) {
        InputValidation.no_input => {
            _ = try stdout.write("Sorry, but you didn't enter any input. Please try again.\n\n");
            return LoopControl.again;
        },
        InputValidation.out_of_range => {
            _ = try stdout.print(
                "You input {s}, a value that is not between 0 and 1.\n\n",
                .{line.?},
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
        InputValidation.ok => |parsed_input| parsed_input,
    };
    if (input_cost == sentinel)
        return LoopControl.stop;

    var num_quarters: u8 = undefined;
    var num_dimes: u8 = undefined;
    var num_nickels: u8 = undefined;
    var num_pennies: u8 = undefined;
    calculateChange(&input_cost, &num_quarters, &num_dimes, &num_nickels, &num_pennies);

    _ = try stdout.print(
        \\
        \\The amount you gave was ${d}, your change is {d} Quarters, {d} Dimes,
        \\{d} Nickels, and {d} Pennies.
        \\
        \\
    , .{ input_cost, num_quarters, num_dimes, num_nickels, num_pennies });

    return LoopControl.again;
}

// -------------------------------------------------------------------------------------------------
fn validate(optional_input: ?[]const u8) InputValidation {
    const sentinel = comptime -1;

    const input: []const u8 = optional_input orelse return InputValidation.no_input;
    if (input.len == 0)
        return InputValidation.no_input;
    const cost_input = std.fmt.parseFloat(f16, input) catch |err|
        return InputValidation{ .input_error = err };
    if (cost_input == sentinel)
        return InputValidation{ .ok = cost_input };
    if (cost_input < 0 or cost_input > 1)
        return InputValidation.out_of_range;

    return InputValidation{ .ok = cost_input };
}

// -------------------------------------------------------------------------------------------------
fn calculateChange(
    input_cost: *const f16,
    num_quarters: *u8,
    num_dimes: *u8,
    num_nickels: *u8,
    num_pennies: *u8,
) void {
    const cost_cents: u8 = @intFromFloat(input_cost.* * 100);
    var change: u8 = cost_cents;

    num_quarters.* = change / 25;
    change %= 25;
    num_dimes.* = change / 10;
    change %= 10;
    num_nickels.* = change / 5;
    change %= 5;
    num_pennies.* = change;
}
