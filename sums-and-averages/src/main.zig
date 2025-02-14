const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const Sums = struct {
    positive: f32,
    negatice: f32,
    overall: f32,
};

const Counts = struct {
    positive: u16,
    negative: u16,
    overall: u16,
};

const Averages = struct {
    positive: f32,
    negative: f32,
    overall: f32,
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

    _ = try stdout.write("\n\nPlease input a sentence. If you want to exit, just hit enter.\n");
    const line = try stdin.readUntilDelimiterOrEof(&input_buf, sentinel);
    if (line.?.len <= 0)
        return LoopControl.stop;

    const input = line.?;

    return LoopControl.again;
}
