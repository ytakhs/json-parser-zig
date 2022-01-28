const TokenType = enum { l_brace, r_brace, l_bracket, r_bracket, colon, period, null, true, false, number, string };
const TokenValue = union { number: f64, string: []u8, bool: bool };
const Token = struct {
    type: TokenType,
    literal: []u8,
    value: ?TokenValue,

    pub fn init(type: TokenType, literal: []u8, value: ?TokenValue) Token {
        return Token{
            .type = type,
            .literal = literal,
            .value = value,
        };
    }

    pub fn lookup_keyword(literal: []u8) ?Token {
        const ty = switch (literal) {
            "null" => TokenType.null,
            "true" => TokenType.true,
            "false" => TokenType.false,
        };
    }
};
