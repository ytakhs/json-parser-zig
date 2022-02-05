const std = @import("std");
const mem = std.mem;
const unicode = std.unicode;

const Token = @import("token.zig").Token;

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

    pub fn next(self: *Self) ?Token {
        self.skipWhitespace();

        return self.symbolToken();
    }

    fn symbolToken(self: *Self) ?Token {
        if (self.nextCodepoint()) |cp| {
            switch (cp) {
                else => return null,
            }
        } else {
            return null;
        }
    }

    fn skipWhitespace(self: *Self) void {
        while (self.peekCodepoint()) |cp| {
            switch (cp) {
                '\u{0020}', '\r', '\n', '\t' => {
                    _ = self.nextCodepointSlice();
                },
                else => break,
            }
        }
    }

    fn peekCodepoint(self: *Self) ?u21 {
        const pk = self.peek(1);
        if (mem.eql(u8, pk, "")) {
            return null;
        }

        return unicode.utf8Decode(pk) catch unreachable;
    }

    fn nextCodepoint(self: *Self) ?u21 {
        return self.iter.nextCodepoint();
    }

    fn peek(self: *Self, n: u64) []const u8 {
        return self.iter.peek(n);
    }

    fn nextCodepointSlice(self: *Self) ?[]const u8 {
        return self.iter.nextCodepointSlice();
    }
};
