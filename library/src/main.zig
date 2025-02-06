const std = @import("std");
const stdout = std.io.getStdOut().writer();

const string_len: i8 = 100;

const Book = struct {
    year: u16,
    genre: Genre,
    title: [string_len]u8,
    author: [string_len]u8,
};

const Genre = enum {
    fiction,
    non_fiction,
    science_fiction,
    mystery,
    biography,
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
test genre_to_string {
    const b: Book = .{
        .title = "Sherlock Holmes",
        .author = "Arthur Conan Doyle",
        .genre = Genre.mystery,
        .year = 1892,
    };
    std.testing.expect(std.mem.eql(u8, genre_to_string(b), "Mystery"));
}

fn genre_to_string(book: Book) []u8 {
    return switch (book.genre) {
        .fiction => "Fiction",
        .non_fiction => "Non-fiction",
        .biography => "Biography",
        .mystery => "Mystery",
        .science_fiction => "Science Fiction",
    };
}

// -------------------------------------------------------------------------------------------------
//fn print_book(book: Book) []u8 {}
