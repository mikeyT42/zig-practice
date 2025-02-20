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
        loop_control = try input_loop();
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
fn input_loop() !void {
    const buf_len: u8 = comptime 100;
    const sentinel: u8 = comptime '\n';

    _ = try stdout.write(
        \\Please enter a string that is a palindrome; if you want to exit then then just hit enter.
        \\It can be a sentence or a word.
        \\
    );

    var input_buf: [buf_len]u8 = undefined;
    const line = try stdin.readUntilDelimiterOrEof(&input_buf, sentinel);
    const input = line orelse "";
    if (input.len == 0)
        return LoopControl.stop;
}

// -------------------------------------------------------------------------------------------------
test "clean_input space begin middle end" {
    var input: [12]u8 = .{ ' ', 'n', 'u', 'r', 's', 'e', 's', ' ', 'r', 'u', 'n', ' ' };
    const output = try clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

test "clean_input space begin middle" {
    var input: [11]u8 = .{ ' ', 'n', 'u', 'r', 's', 'e', 's', ' ', 'r', 'u', 'n' };
    const output = try clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

test "clean_input space middle" {
    var input: [10]u8 = .{ 'n', 'u', 'r', 's', 'e', 's', ' ', 'r', 'u', 'n' };
    const output = try clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

test "clean_input no space" {
    var input: [9]u8 = .{ 'n', 'u', 'r', 's', 'e', 's', 'r', 'u', 'n' };
    const output = try clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

fn clean_input(input: []u8) ![]u8 {
    _ = try stdout.write(
        \\----
        \\Cleaning the input
        \\----
        \\
    );

    var len: u8 = 0;
    for (input, 0..) |*character, i| {
        _ = try stdout.print("input[i={d}] = {c}\n", .{ i, character.* });
        if (std.ascii.isAlphanumeric(character.*)) {
            character.* = std.ascii.toLower(character.*);
            len += 1;
            _ = try stdout.print("len = {d}\n", .{len});
            continue;
        }

        for (input[i .. input.len - 1], i..) |*character_move, j| {
            _ = try stdout.print("input[j={d}] = {c}\n", .{ j, character_move.* });
            _ = try stdout.print("input[j+1={d}] = {c}\n", .{ j + 1, input[j + 1] });
            character_move.* = input[j + 1];
        }
    }

    return input[0..len];
}
