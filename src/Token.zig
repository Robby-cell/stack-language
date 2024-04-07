const Token = @This();

pub const Position = struct {
    start: u32,
    end: u32,
};

pub const Type = enum {
    number,
    pop,
    push,
    add,
    sub,
    mul,
    div,

    print,

    invalid,
    eof,
};

type: Type,
position: Position,

pub inline fn lexeme(token: Token, buffer: []const u8) []const u8 {
    return buffer[token.position.start..token.position.end];
}
