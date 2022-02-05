const std = @import("std");
const mem = std.mem;
const unicode = std.unicode;

const Token = @import("token.zig").Token;

const LexerError = error{InvalidKeyword};

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

    pub fn next(self: *Self) LexerError!?Token {
        self.skipWhitespace();

        if (try self.keywordToken()) |tok| {
            return tok;
        }

        return self.symbolToken();
    }

    fn keywordToken(self: *Self) LexerError!?Token {
        if (self.peekCodepoint()) |cp| {
            switch (cp) {
                // t
                '\u{0074}' => {
                    if (mem.eql(u8, self.peek(4), "true")) {
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();

                        return Token.True;
                    } else {
                        return LexerError.InvalidKeyword;
                    }
                },
                // f
                '\u{0066}' => {
                    if (mem.eql(u8, self.peek(5), "false")) {
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();

                        return Token.False;
                    } else {
                        return LexerError.InvalidKeyword;
                    }
                },
                // n
                '\u{006e}' => {
                    if (mem.eql(u8, self.peek(4), "null")) {
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();
                        _ = self.nextCodepoint();

                        return Token.Null;
                    } else {
                        return LexerError.InvalidKeyword;
                    }
                },
                else => return null,
            }
        }

        return null;
    }

    fn symbolToken(self: *Self) ?Token {
        if (self.nextCodepoint()) |cp| {
            switch (cp) {
                '\u{007B}' => return Token.LBracket,
                '\u{007D}' => return Token.RBracket,
                '\u{005B}' => return Token.LBrace,
                '\u{005D}' => return Token.RBrace,
                '\u{003A}' => return Token.Colon,
                '\u{002C}' => return Token.Comma,
                '\u{002E}' => return Token.Period,
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
