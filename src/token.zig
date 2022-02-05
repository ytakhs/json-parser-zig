pub const Token = union(enum) {
    LBrace,
    RBrace,
    LBracket,
    RBracket,
    Colon,
    Period,
    Null,
    True,
    False,
    Number: struct {},
    String: struct {},
};
