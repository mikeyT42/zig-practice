const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

const growth_factor = 10;

pub const List = struct {
    const Self = @This();
    // =============================================================================================
    //
    //      Fields
    //
    // =============================================================================================
    ///This should not be written to by anyone outside.
    len: usize,
    ///The dynamically allocated array.
    data: []i32,
    allocator: std.mem.Allocator,

    // =============================================================================================
    //
    //      Public Functions
    //
    // =============================================================================================
    ///Be sure to call destroy on this struct so that the allocated memory is freed.
    pub fn create(allocator: std.mem.Allocator) std.mem.Allocator.Error!Self {
        const data = allocator.alloc(i32, growth_factor) catch |err| {
            _ = stderr.write("Could not alloc data in List.\n\n") catch unreachable;
            return err;
        };

        const list = Self{
            .len = 0,
            .allocator = allocator,
            .data = data,
        };
        _ = stdout.write("List created.\n") catch unreachable;
        return list;
    }

    // ---------------------------------------------------------------------------------------------
    pub fn destroy(self: *Self) void {
        self.allocator.free(self.data);
        self.len = 0;
        self.data.len = 0;
    }

    // ---------------------------------------------------------------------------------------------
    pub fn pop(self: *Self) i32 {
        const i = self.data[self.len - 1];
        self.len -= 1;
        return i;
    }

    // ---------------------------------------------------------------------------------------------
    pub fn put(self: *Self, i: i32) std.mem.Allocator.Error!void {
        _ = stdout.print(
            "length = {d} ; capacity = {}\n",
            .{ self.len, self.data.len },
        ) catch unreachable;

        if (self.len >= self.data.len) {
            _ = stdout.write("Reallocating.\n") catch unreachable;
            const new_array_size = growth_factor + self.data.len;
            self.data = self.allocator.realloc(self.data, new_array_size) catch |err| {
                _ = stderr.write("\n\nCould not realloc data in List.\n\n") catch unreachable;
                return err;
            };
        }

        self.len += 1;
        self.data[self.len - 1] = i;
    }

    // ---------------------------------------------------------------------------------------------
    pub fn shrinkToFit(self: *Self) std.mem.Allocator.Error!void {
        const diff = self.data.len - self.len;
        const can_reduce_size = diff > 0;
        _ = stdout.print("diff = {}\n", .{diff}) catch unreachable;
        _ = stdout.print("can_reduce_size = {}\n", .{can_reduce_size}) catch unreachable;
        _ = stdout.print(
            "length = {} ; capacity = {}\n",
            .{ self.len, self.data.len },
        ) catch unreachable;

        if (can_reduce_size) {
            const new_array_size = self.len;
            _ = stdout.print("new_array_size = {d}\n", .{new_array_size}) catch unreachable;
            self.data = self.allocator.realloc(self.data, new_array_size) catch |err| {
                _ = stderr.write("\n\nCould not realloc data in List.\n\n") catch unreachable;
                return err;
            };
            _ = stdout.print(
                "length = {d} ; capacity = {d}\n",
                .{ self.len, self.data.len },
            ) catch unreachable;
        }
    }
};

// =================================================================================================
//
//      Tests
//
// =================================================================================================
test "List creation and deletion" {
    const allocator = std.testing.allocator;
    var list = try List.create(allocator);
    defer list.destroy();
    _ = try std.testing.expectEqual(0, list.len);
    _ = try std.testing.expectEqual(growth_factor, list.data.len);
}

// -------------------------------------------------------------------------------------------------
test "List creation and deletion emphasized" {
    const allocator = std.testing.allocator;
    var list = try List.create(allocator);
    list.destroy();
    _ = try std.testing.expectEqual(0, list.len);
    _ = try std.testing.expectEqual(0, list.data.len);
}

// -------------------------------------------------------------------------------------------------
test "List put" {
    const allocator = std.testing.allocator;
    var list = try List.create(allocator);
    defer list.destroy();
    for (0..9) |i| {
        _ = try stdout.print("i = {}\n", .{i + 1});
        try list.put(@intCast(i + 1));
    }
    _ = try stdout.print("i = {}\n", .{10});
    try list.put(10);
    _ = try stdout.print("i = {}\n", .{11});
    try list.put(11);

    _ = try std.testing.expectEqual(20, list.data.len);
    _ = try std.testing.expectEqual(11, list.len);
}

// -------------------------------------------------------------------------------------------------
test "List pop" {
    const allocator = std.testing.allocator;
    var list = try List.create(allocator);
    defer list.destroy();
    for (0..11) |i| {
        _ = try stdout.print("i = {}\n", .{i + 1});
        try list.put(@intCast(i + 1));
    }

    _ = try std.testing.expectEqual(11, list.len);
    const popped = list.pop();

    _ = try std.testing.expectEqual(20, list.data.len);
    _ = try std.testing.expectEqual(10, list.len);
    _ = try std.testing.expectEqual(11, popped);
}

// -------------------------------------------------------------------------------------------------
test "List shrinkToFit" {
    const allocator = std.testing.allocator;
    var list = try List.create(allocator);
    defer list.destroy();
    for (0..12) |i| {
        _ = try stdout.print("i = {}\n", .{i + 1});
        try list.put(@intCast(i + 1));
    }

    _ = try std.testing.expectEqual(20, list.data.len);
    _ = try std.testing.expectEqual(12, list.len);

    try list.shrinkToFit();
    _ = try std.testing.expectEqual(12, list.data.len);
    _ = try std.testing.expectEqual(12, list.len);
}
