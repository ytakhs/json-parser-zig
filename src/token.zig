pub const Token = union(enum) {
    LBrace,
    RBrace,
    LBracket,
    RBracket,
    Colon,
    Comma,
    Period,
    Null,
    True,
    False,
    Number: struct {
        value: f64,
    },
    String: struct {
        value: []u8,
    },
};
