const std = @import("std");
const List = @import("./list.zig").List;
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();
const stdin = std.io.getStdIn().reader();

pub fn main() !void {
    try clear();
    _ = try stdout.write(
        \\------------------------------------------------------------------------------------------
        \\                              Welcome to the List Program
        \\------------------------------------------------------------------------------------------
        \\
        \\
    );
    _ = try stdout.write(
        \\-----------------------------------------------------------------------
        \\                          Creating the List
        \\-----------------------------------------------------------------------
        \\
        \\
    );
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var list = try List.create(allocator);
    _ = try stdout.print("List length = {d}\n", .{list.len});

    _ = try stdout.write(
        \\-----------------------------------------------------------------------
        \\                          Filling the List
        \\-----------------------------------------------------------------------
        \\
        \\
    );
    try list.put(1);
    try list.put(2);
    try list.put(3);
    try list.put(4);
    try list.put(5);
    try list.put(6);
    try list.put(7);
    try list.put(8);
    try list.put(9);
    _ = try stdout.print("List length = {d}\n", .{list.len});
    for (list.data[0..list.len], 0..) |item, i| {
        _ = try stdout.print("item at {d} = {d}\n", .{ i, item });
    }

    try list.put(10);
    _ = try stdout.print("List length = {d}\n", .{list.len});
    for (list.data[0..list.len], 0..) |item, i| {
        _ = try stdout.print("item at {d} = {d}\n", .{ i, item });
    }
    try list.shrinkToFit();

    _ = try stdout.write(
        \\-----------------------------------------------------------------------
        \\                          First Reallocation
        \\-----------------------------------------------------------------------
        \\
        \\
    );
    try list.put(11);
    _ = try stdout.print("List length = {d}\n", .{list.len});
    for (list.data[0..list.len], 0..) |item, i| {
        _ = try stdout.print("item at {d} = {d}\n", .{ i, item });
    }

    try list.put(12);
    try list.put(13);
    try list.put(14);
    try list.put(15);
    try list.put(16);
    try list.put(17);
    try list.put(18);
    try list.put(19);
    try list.put(20);

    _ = try stdout.write(
        \\-----------------------------------------------------------------------
        \\                          Second Reallocation
        \\-----------------------------------------------------------------------
        \\
        \\
    );
    try list.put(21);
    try list.put(22);
    try list.put(23);
    try list.put(24);
    try list.put(25);
    try list.put(26);
    try list.put(27);
    try list.put(28);
    try list.put(29);
    try list.put(30);

    _ = try stdout.write(
        \\-----------------------------------------------------------------------
        \\                          Third Reallocation
        \\-----------------------------------------------------------------------
        \\
        \\
    );
    try list.put(31);
    try list.put(32);
    try list.put(33);
    _ = try stdout.print("List length = {d}\n", .{list.len});
    for (list.data[0..list.len], 0..) |item, i| {
        _ = try stdout.print("item at {d} = {d}\n", .{ i, item });
    }

    _ = try stdout.write(
        \\-----------------------------------------------------------------------
        \\                          Removing and Shrinking
        \\-----------------------------------------------------------------------
        \\
        \\
    );
    const popped = list.pop();
    _ = try stdout.print("Popped = {d}\n", .{popped});
    _ = list.pop();
    _ = list.pop();
    try list.shrinkToFit();

    _ = try stdout.write(
        \\-----------------------------------------------------------------------
        \\                          Destroying
        \\-----------------------------------------------------------------------
        \\
        \\
    );
    list.destroy();

    _ = try stdout.write(
        \\
        \\------------------------------------------------------------------------------------------
        \\                                Dhank you, come again. 
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
