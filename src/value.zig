const std = @import("std");

pub const ArrayValue = std.MultiArrayList(Value);

pub const Value = union(enum) {
    String: struct { value: []u8 },
    Number: struct { value: f64 },
    Object,
    Array: ArrayValue,
    Null,
    True,
    False,
};
