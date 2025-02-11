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
    const total_keystrokes = keystrokes(input);
    _ = try stdout.print("\nKeystrokes: {d: <10}", .{total_keystrokes});
    const total_alpha = alpha_chars(input);
    _ = try stdout.print("\nAlpha Characters: {d: <4}", .{total_alpha});

    return LoopControl.again;
}

// -------------------------------------------------------------------------------------------------
fn keystrokes(input: []const u8) u8 {
    // This is me assuming input.len will fit into u8.
    return @intCast(input.len);
}

test keystrokes {
    _ = try std.testing.expectEqual(keystrokes(@as([]const u8, "Hello there 12.")), 15);
}

// -------------------------------------------------------------------------------------------------
fn alpha_chars(input: []const u8) u8 {
    var total_alpha: u8 = 0;

    for (input) |char| {
        if (!std.ascii.isAlphabetic(char))
            continue;

        total_alpha += 1;
    }

    return total_alpha;
}

test alpha_chars {
    _ = try std.testing.expectEqual(alpha_chars(@as([]const u8, "Hello there 12.")), 10);
}

// -------------------------------------------------------------------------------------------------
fn digit_chars(input: []const u8) u8 {
    var total_digit: u8 = 0;

    for (input) |char| {
        if (!std.ascii.isAlphanumeric(char))
            continue;
        if (std.ascii.isAlphabetic(char))
            continue;
        // Only thing left is that char is numeric.
        total_digit += 1;
    }

    return total_digit;
}

test digit_chars {
    _ = try std.testing.expectEqual(digit_chars(@as([]const u8, "Hello there 12.")), 2);
}
