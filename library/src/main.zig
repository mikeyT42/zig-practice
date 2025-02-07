const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Book = struct {
    year: u16,
    genre: Genre,
    title: []const u8,
    author: []const u8,
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

    const library = [_]Book{
        .{
            .title = "The Great Gatsby",
            .author = "F. Scott Fitzgerald",
            .genre = Genre.fiction,
            .year = 1925,
        },
        .{
            .title = "Harry Potter and the Sorcer's Stone",
            .author = "J. K. Rowling",
            .genre = Genre.fiction,
            .year = 1997,
        },
        .{
            .title = "The War of the Worlds",
            .author = "H. G. Wells",
            .genre = Genre.science_fiction,
            .year = 1898,
        },
        .{
            .title = "Sherlock Holmes",
            .author = "Arthur Conan Doyle",
            .genre = Genre.mystery,
            .year = 1892,
        },
        .{
            .title = "Steve Jobs",
            .author = "Arthur Isaacson",
            .genre = Genre.biography,
            .year = 2011,
        },
        .{
            .title = "Philosophiae Naturalis Principia Mathematica",
            .author = "Sir Isaac Newton",
            .genre = Genre.non_fiction,
            .year = 1687,
        },
    };

    _ = try stdout.print("Our library has {d} books.\n\n", .{library.len});

    try print_book(library[0]);
    try print_book(library[1]);
    try print_book(library[2]);
    try print_book(library[3]);
    try print_book(library[4]);
    try print_book(library[5]);

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
    try std.testing.expect(std.mem.eql(u8, genre_to_string(b), "Mystery"));
}

fn genre_to_string(book: Book) []const u8 {
    return switch (book.genre) {
        .fiction => "Fiction",
        .non_fiction => "Non-fiction",
        .biography => "Biography",
        .mystery => "Mystery",
        .science_fiction => "Science Fiction",
    };
}

// -------------------------------------------------------------------------------------------------
fn print_book(book: Book) !void {
    _ = try stdout.print(
        \\book [
        \\  title = {s}
        \\  author = {s}
        \\  year = {d}
        \\  genre = {s}
        \\]
        \\
    , .{ book.title, book.author, book.year, genre_to_string(book) });
}
