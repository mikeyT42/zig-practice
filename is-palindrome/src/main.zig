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
        \\                              Welcome the Point Inputter
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
        \\                                 Dhank you, come again. 
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

    const cleaned_input = clean_input(@constCast(input));
    if (try is_palindrome(cleaned_input)) {
        _ = try stdout.print("\n\"{s}\" is a palindrome.\n\n", .{cleaned_input});
    } else {
        _ = try stdout.print("\n\"{s}\" is not a palindrome.\n\n", .{cleaned_input});
    }

    return LoopControl.again;
}

// -------------------------------------------------------------------------------------------------
test "clean_input space begin middle end" {
    var input: [12]u8 = .{ ' ', 'n', 'u', 'r', 's', 'e', 's', ' ', 'r', 'u', 'n', ' ' };
    const output = clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

test "clean_input space begin middle" {
    var input: [11]u8 = .{ ' ', 'n', 'u', 'r', 's', 'e', 's', ' ', 'r', 'u', 'n' };
    const output = clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

test "clean_input space middle" {
    var input: [10]u8 = .{ 'n', 'u', 'r', 's', 'e', 's', ' ', 'r', 'u', 'n' };
    const output = clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

test "clean_input space double middle" {
    var input: [11]u8 = .{ 'n', 'u', 'r', 's', 'e', 's', ' ', ' ', 'r', 'u', 'n' };
    const output = clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

test "clean_input no space" {
    var input: [9]u8 = .{ 'n', 'u', 'r', 's', 'e', 's', 'r', 'u', 'n' };
    const output = clean_input(&input);
    _ = try stdout.print("[{s}]\n", .{output});
    _ = try std.testing.expectEqualStrings("nursesrun", output);
    _ = try std.testing.expect(output.len == 9);
}

fn clean_input(input: []u8) []const u8 {
    var trimmed_input: []u8 = @constCast(std.mem.trim(u8, input, &std.ascii.whitespace));
    var new_len: usize = 0;
    var i: usize = 0;
    var iteration: usize = 0;
    while (iteration < trimmed_input.len) : ({
        i += 1;
        iteration += 1;
    }) {
        if (std.ascii.isAlphanumeric(trimmed_input[i])) {
            trimmed_input[i] = std.ascii.toLower(trimmed_input[i]);
            new_len = i + 1;
            continue;
        }

        for (trimmed_input[i .. trimmed_input.len - 1], i..) |*character_move, j| {
            character_move.* = trimmed_input[j + 1];
            trimmed_input[j + 1] = ' ';
        }

        // Move back one index so that we continue from where we left off.
        i -= 1;
    }

    return trimmed_input[0..new_len];
}

// -------------------------------------------------------------------------------------------------
test "a palindrome" {
    _ = try std.testing.expect(is_palindrome("nursesrun") catch unreachable);
}

test "not a palindrome" {
    _ = try std.testing.expect(is_palindrome("hello") catch unreachable == false);
}

test "a palindrome even length" {
    _ = try std.testing.expect(is_palindrome("noon") catch unreachable);
}

fn is_palindrome(string: []const u8) !bool {
    _ = try stdout.write(
        \\----
        \\Checking for palindrome.
        \\----
        \\
    );

    var i: usize = 0;
    while (i < string.len / 2) : (i += 1) {
        _ = try stdout.print("left finger at {d} -> {c}\n", .{ i, string[i] });
        _ = try stdout.print(
            "right finger at {d} -> {c}\n",
            .{ string.len - i - 1, string[string.len - i - 1] },
        );

        if (string[i] != string[string.len - i - 1])
            return false;
    }

    return true;
}
