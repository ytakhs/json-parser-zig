pub const Value = union(enum) {
    String: struct { value: []u8 },
    Number: struct { value: f64 },
    Object,
    Array,
    Null,
    True,
    False,
};
