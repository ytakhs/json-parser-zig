const std = @import("std");
const mem = std.mem;
const unicode = std.unicode;

const Token = @import("token.zig").Token;

const LexerError = error{ InvalidKeyword, InvalidNumber, Allocation };

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

        if (try self.stringToken()) |tok| {
            return tok;
        }

        if (try self.numberToken()) |tok| {
            return tok;
        }

        if (try self.keywordToken()) |tok| {
            return tok;
        }

        return self.symbolToken();
    }

    fn stringToken(self: *Self) LexerError!?Token {
        var buf = std.ArrayList(u8).init(self.allocator);

        if (self.peekCodepoint()) |cp| {
            switch (cp) {
                '"' => {
                    self.skip(1);

                    while (self.peekCodepoint()) |cp2| {
                        switch (cp2) {
                            '"' => {
                                self.skip(1);
                                break;
                            },
                            else => {
                                const v = self.nextCodepointSlice().?;

                                buf.appendSlice(v) catch return LexerError.Allocation;
                            },
                        }
                    }
                },
                else => return null,
            }
        }

        if (buf.items.len > 0) {
            return Token{ .String = .{ .value = buf.items } };
        }

        return null;
    }

    fn numberToken(self: *Self) LexerError!?Token {
        if (self.peekCodepoint()) |cp| {
            switch (cp) {
                '0'...'@', '-' => {},
                else => return null,
            }
        }

        var al = std.ArrayList(u8).init(self.allocator);

        while (self.peekCodepoint()) |cp| {
            switch (cp) {
                '0'...'@', '.', 'e', 'E', '+', '-' => {
                    const v = self.nextCodepointSlice().?;
                    al.appendSlice(v) catch return LexerError.Allocation;
                },
                else => break,
            }
        }

        if (al.items.len > 0) {
            const value = std.fmt.parseFloat(f64, al.items) catch return LexerError.InvalidNumber;

            return Token{ .Number = .{ .value = value } };
        }

        return null;
    }

    fn keywordToken(self: *Self) LexerError!?Token {
        if (self.peekCodepoint()) |cp| {
            switch (cp) {
                // t
                't' => {
                    if (mem.eql(u8, self.peek(4), "true")) {
                        self.skip(4);

                        return Token.True;
                    } else {
                        return LexerError.InvalidKeyword;
                    }
                },
                // f
                'f' => {
                    if (mem.eql(u8, self.peek(5), "false")) {
                        self.skip(5);

                        return Token.False;
                    } else {
                        return LexerError.InvalidKeyword;
                    }
                },
                // n
                'n' => {
                    if (mem.eql(u8, self.peek(4), "null")) {
                        self.skip(4);

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
                '[' => return Token.LBracket,
                ']' => return Token.RBracket,
                '{' => return Token.LBrace,
                '}' => return Token.RBrace,
                ':' => return Token.Colon,
                ',' => return Token.Comma,
                '.' => return Token.Period,
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

    fn skip(self: *Self, n: usize) void {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            _ = self.nextCodepointSlice();
        }
    }

    fn nextCodepointSlice(self: *Self) ?[]const u8 {
        return self.iter.nextCodepointSlice();
    }
};
