const std = @import("std");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var args = try std.process.argsWithAllocator(arena.allocator());
    _ = args.skip();
    const filename = try args.next(arena.allocator()) orelse unreachable;
    const data = try std.fs.cwd().readFileAlloc(arena.allocator(), filename, 1000);

    std.debug.print("{s}", .{data});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
