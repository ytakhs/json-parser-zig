const std = @import("std");
const Token = @import("token.zig").Token;
const Lexer = @import("lexer.zig").Lexer;
const Value = @import("value.zig").Value;

pub const Parser = struct {
    allocator: std.mem.Allocator,
    lexer: Lexer,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, bytes: []u8) !Self {
        var lexer = try Lexer.init(allocator, bytes);

        return Self{
            .allocator = allocator,
            .lexer = lexer,
        };
    }

    pub fn parse(self: *Self) !Value {
        var tok = (try self.lexer.next()) orelse unreachable;

        switch (tok) {
            Token.Null => return parseNull(),
            Token.True => return parseTrue(),
            Token.False => return parseFalse(),
            Token.Number => |t| return parseNumber(t.value),
            Token.String => |t| return parseString(t.value),
            else => unreachable,
        }
    }

    pub fn parseNull() Value {
        return Value.Null;
    }

    pub fn parseTrue() Value {
        return Value.True;
    }

    pub fn parseFalse() Value {
        return Value.False;
    }

    pub fn parseNumber(value: f64) Value {
        return Value{ .Number = .{ .value = value } };
    }

    pub fn parseString(value: []u8) Value {
        return Value{ .String = .{ .value = value } };
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
};
