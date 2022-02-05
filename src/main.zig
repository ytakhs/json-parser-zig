const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var args = try std.process.argsWithAllocator(arena.allocator());
    _ = args.skip();
    const filename = try args.next(arena.allocator()).?;
    const data = try std.fs.cwd().readFileAlloc(arena.allocator(), filename, 1000);

    var lexer = try Lexer.init(arena.allocator(), data);
    var alloc = arena.allocator();

    while (lexer.next()) |val| {
        const size = std.unicode.utf8CodepointSequenceLength(val) catch unreachable;
        var buf = try alloc.alloc(u8, size);
        _ = std.unicode.utf8Encode(val, buf) catch unreachable;

        std.debug.print("{s}", .{buf});
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
