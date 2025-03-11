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
    );
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var list = try List.create(allocator);
    defer list.destroy();
    _ = try stdout.print("List length = {d}\n", .{list.len});

    _ = try stdout.write(
        \\-----------------------------------------------------------------------
        \\                          Filling the List
        \\-----------------------------------------------------------------------
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
    for (list.data, 0..) |item, i| {
        _ = try stdout.print("item at {d} = {d}\n", .{ i, item });
    }

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
