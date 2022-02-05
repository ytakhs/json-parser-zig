const std = @import("std");
const Token = @import("token.zig").Token;
const mem = std.mem;

pub const Lexer = struct {
    allocator: std.mem.Allocator,
    iter: std.unicode.Utf8Iterator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, bytes: []u8) !Self {
        const view = try std.unicode.Utf8View.init(bytes);
        var iter = view.iterator();

        return Self{
            .allocator = allocator,
            .iter = iter,
        };
    }

    pub fn next(self: *Self) ?u21 {
        self.skipWhitespace();

        return self.nextCodepoint();
    }

    fn skipWhitespace(self: *Self) void {
        while (true) {
            const peek = self.iter.peek(1);

            if (mem.eql(u8, peek, " ")) {
                _ = self.nextCodepoint();
            } else if (mem.eql(u8, peek, "\n")) {
                _ = self.nextCodepoint();
            } else if (mem.eql(u8, peek, "\r")) {
                _ = self.nextCodepoint();
            } else if (mem.eql(u8, peek, "\t")) {
                _ = self.nextCodepoint();
            } else {
                break;
            }
        }
    }

    fn nextCodepoint(self: *Self) ?u21 {
        return self.iter.nextCodepoint();
    }
};
