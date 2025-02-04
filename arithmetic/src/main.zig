const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    try clear();
    _ = try stdout.write(
        \\------------------------------------------------------------------------------------------
        \\                                          Welcome
        \\------------------------------------------------------------------------------------------
        \\
        \\
    );

    const x = 5;
    const y = 2;
    var result: i8 = undefined;

    try stdout.print("Adding {} to {}\n", .{ x, y });
    result = add(x, y);
    try stdout.print("result = {}\n\n", .{result});

    try stdout.print("Subtracting {} from {}\n", .{ y, x });
    result = subtract(x, y);
    try stdout.print("result = {}\n\n", .{result});

    try stdout.print("Multiplying {} by {}\n", .{ x, y });
    result = multiply(x, y);
    try stdout.print("result = {}\n\n", .{result});

    try stdout.print("Dividing {} by {}\n", .{ x, y });
    result = divide(x, y);
    try stdout.print("result = {}\n\n", .{result});

    try stdout.print("Getting the remainder of the division of {} by {}\n", .{ x, y });
    result = modulus(x, y);
    try stdout.print("result = {}\n\n", .{result});

    try stdout.print("Raising {} by the power of {}\n", .{ x, y });
    result = power(x, y);
    try stdout.print("result = {}\n\n", .{result});

    _ = try stdout.write(
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
test add {
    try std.testing.expect(add(1, 1) == 2);
}

fn add(x: i8, y: i8) i8 {
    return x + y;
}

// -------------------------------------------------------------------------------------------------
test subtract {
    try std.testing.expect(subtract(100, 99) == 1);
}

fn subtract(x: i8, y: i8) i8 {
    return x - y;
}

// -------------------------------------------------------------------------------------------------
test multiply {
    try std.testing.expect(multiply(50, 2) == 100);
}

fn multiply(x: i8, y: i8) i8 {
    return x * y;
}

// -------------------------------------------------------------------------------------------------
test divide {
    try std.testing.expect(divide(5, 2) == 2);
}

fn divide(x: i8, y: i8) i8 {
    return @divTrunc(x, y);
}

// -------------------------------------------------------------------------------------------------
test modulus {
    try std.testing.expect(modulus(5, 2) == 1);
}

fn modulus(x: i8, y: i8) i8 {
    return @mod(x, y);
}

// -------------------------------------------------------------------------------------------------
test power {
    try std.testing.expect(power(5, 2) == 25);
}

fn power(x: i8, y: i8) i8 {
    return std.math.pow(i8, x, y);
}
