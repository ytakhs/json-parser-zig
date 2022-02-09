const std = @import("std");
const Token = @import("token.zig").Token;
const Lexer = @import("lexer.zig").Lexer;
const val = @import("value.zig");
const Value = val.Value;
const ArrayValue = val.ArrayValue;

pub const ParseError = error{
    Lexer,
    Parse,
    Allocation,
};

pub const Parser = struct {
    allocator: std.mem.Allocator,
    lexer: Lexer,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, bytes: []u8) ParseError!Self {
        var lexer = Lexer.init(allocator, bytes) catch return ParseError.Lexer;

        return Self{
            .allocator = allocator,
            .lexer = lexer,
        };
    }

    pub fn parse(self: *Self) ParseError!Value {
        var tok = (self.lexer.next() catch return ParseError.Lexer).?;

        return self.parseValue(tok);
    }

    fn parseValue(self: *Self, token: Token) ParseError!Value {
        _ = self;
        switch (token) {
            Token.Null => return parseNull(),
            Token.True => return parseTrue(),
            Token.False => return parseFalse(),
            Token.Number => |t| return parseNumber(t.value),
            Token.String => |t| return parseString(t.value),
            Token.LBracket => {
                return self.parseArray();
            },
            else => unreachable,
        }
    }

    fn parseNull() Value {
        return Value.Null;
    }

    fn parseTrue() Value {
        return Value.True;
    }

    fn parseFalse() Value {
        return Value.False;
    }

    fn parseNumber(value: f64) Value {
        return Value{ .Number = .{ .value = value } };
    }

    fn parseString(value: []u8) Value {
        return Value{ .String = .{ .value = value } };
    }

    fn parseArray(self: *Self) ParseError!Value {
        var res = ArrayValue{};

        while (self.lexer.next() catch return ParseError.Lexer) |tok| {
            switch (tok) {
                Token.RBracket => break,
                Token.Comma => {},
                else => {},
            }
        }

        return Value{ .Array = res };
    }

    test "string" {
        var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
        defer arena.deinit();

        var input = "\"foo\"".*;
        var expected = "foo".*;
        var parser = try Parser.init(arena.allocator(), input[0..input.len]);

        try std.testing.expect(std.mem.eql(u8, (try parser.parse()).String.value, expected[0..expected.len]));
    }

    test "number" {
        var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
        defer arena.deinit();

        var input = "1".*;
        const expected: f64 = 1.0;
        var parser = try Parser.init(arena.allocator(), input[0..input.len]);

        try std.testing.expect((try parser.parse()).Number.value == expected);
    }

    test "null" {
        var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
        defer arena.deinit();

        var input = "null".*;
        const expected = Value.Null;
        var parser = try Parser.init(arena.allocator(), input[0..input.len]);

        try std.testing.expect((try parser.parse()) == expected);
    }

    test "true" {
        var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
        defer arena.deinit();

        var input = "true".*;
        const expected = Value.True;
        var parser = try Parser.init(arena.allocator(), input[0..input.len]);

        try std.testing.expect((try parser.parse()) == expected);
    }

    test "false" {
        var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
        defer arena.deinit();

        var input = "false".*;
        const expected = Value.False;
        var parser = try Parser.init(arena.allocator(), input[0..input.len]);

        try std.testing.expect((try parser.parse()) == expected);
    }

    test "array" {
        var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
        defer arena.deinit();

        var input = "[1]".*;
        var parser = try Parser.init(arena.allocator(), input[0..input.len]);

        const a = parser.parse();

        std.debug.print("{s}", .{@TypeOf(a)});
    }
};
