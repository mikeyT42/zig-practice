const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const LoopControl = enum {
    again,
    stop,
};

const InputValidation = union(enum) { out_of_range: void, no_input: void, input_error: std.fmt.ParseFloatError };

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

    _ = try stdout.write(
        \\Enter the amount you spent to two decimal places: the input must be between 0 and 1: -1 is
        \\to exit.
        \\
    );
    const line = try stdin.readUntilDelimiterOrEof(&input_buf, sentinel);
    if (line.?.len == 0)
        return LoopControl.stop;
}

// -------------------------------------------------------------------------------------------------
fn validate(input: []const u8) InputValidation {
    const sentinel = comptime -1;
    if (input.len == 0)
        return .{.no_input};
    const cost_input = std.fmt.parseFloat(f16, input) catch |err| return .{ .input_error = err };
    if (cost_input == sentinel)
        return .{.no_input};
    if (cost_input < 0 || cost_input > 1)}
        return .{ .no_input };
}
