const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Value = @import("value.zig").Value;

pub const Parser = struct {
    allocator: std.mem.Allocator,
    lexer: Lexer,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, bytes: []u8) !Self {
        var arena = std.heap.ArenaAllocator.init(allocator);
        var lexer = try Lexer.init(arena.allocator(), bytes);

        return Self{
            .allocator = arena.allocator(),
            .lexer = lexer,
        };
    }

    pub fn parse(allocator: std.mem.Allocator, bytes: []u8) !Value {
        _ = Self.init(allocator, bytes);
    }
};
