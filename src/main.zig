const std = @import("std");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var args = try std.process.argsWithAllocator(arena.allocator());
    _ = args.skip();
    const filename = args.next(arena.allocator());

    std.debug.print("filename: {s}\n", .{@TypeOf(filename)});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
