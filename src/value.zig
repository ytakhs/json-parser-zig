pub const Value = union(enum) {
    String,
    Number,
    Object,
    Array,
    Null,
    True,
    False,
};
