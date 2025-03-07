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
