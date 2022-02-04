const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var args = try std.process.argsWithAllocator(arena.allocator());
    _ = args.skip();
    const filename = try args.next(arena.allocator()).?;
    const data = try std.fs.cwd().readFileAlloc(arena.allocator(), filename, 1000);

    const lexer = Lexer.init(arena.allocator(), data);
    std.debug.print("{s}\n", .{@TypeOf(lexer)});

    const view = try std.unicode.Utf8View.init(data);
    var iter = view.iterator();

    const a = iter.nextCodepointSlice().?;

    std.debug.print("{s}\n", .{a});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
