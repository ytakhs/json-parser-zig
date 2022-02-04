const std = @import("std");

pub const Lexer = struct {
    allocator: std.mem.Allocator,
    bytes: []u8,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, bytes: []u8) Self {
        return Self{
            .allocator = allocator,
            .bytes = bytes,
        };
    }
};
