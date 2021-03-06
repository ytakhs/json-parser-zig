const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Parser = @import("parser.zig").Parser;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var args = try std.process.argsWithAllocator(arena.allocator());
    _ = args.skip();
    const filename = try args.next(arena.allocator()).?;
    const data = try std.fs.cwd().readFileAlloc(arena.allocator(), filename, 1000);

    var lexer = try Lexer.init(arena.allocator(), data);
    while (try lexer.next()) |val| {
        std.debug.print("{s}.{s}\n", .{ @TypeOf(val), @tagName(val) });
    }
}

test {
    _ = Lexer;
    _ = Parser;
}
