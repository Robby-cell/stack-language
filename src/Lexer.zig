const std = @import("std");

const Token = @import("Token.zig");

const Lexer = @This();

const Operation = struct {
    const keywords = std.ComptimeStringMap(Token.Type, .{
        .{ "pop", .pop },
        .{ "push", .push },
        .{ "add", .add },
        .{ "sub", .sub },
        .{ "mul", .mul },
        .{ "div", .div },
        .{ "print", .print },
    });

    inline fn fromLexeme(lexeme: []const u8) ?Token.Type {
        return keywords.get(lexeme);
    }
};

allocator: std.mem.Allocator,
buffer: []u8,
index: u32,
start: struct {
    index: u32 = 0,
},

pub fn init(buffer: []u8, allocator: std.mem.Allocator) Lexer {
    return .{
        .allocator = allocator,
        .buffer = buffer,
        .index = 0,
        .start = .{},
    };
}

fn createFrame(lexer: *Lexer) void {
    lexer.start.index = lexer.index;
}

pub fn nextToken(lexer: *Lexer) Token {
    lexer.skipWhitespace();

    if (lexer.eof()) {
        return lexer.createToken(.eof);
    }

    lexer.createFrame();

    return switch (lexer.peek()) {
        '0'...'9' => lexer.number(),
        'a'...'z', 'A'...'Z' => lexer.operation(),
        else => return lexer.invalidToken(),
    };
}

fn operation(lexer: *Lexer) Token {
    while (std.ascii.isAlphabetic(lexer.peek())) {
        _ = lexer.consume();
    }

    return .{
        .position = .{
            .start = lexer.start.index,
            .end = lexer.index,
        },
        .type = Operation.fromLexeme(lexer.currentLexeme()) orelse .invalid,
    };
}

fn number(lexer: *Lexer) Token {
    lexer.consumeWhileDigit();
    if (lexer.expect('.')) {
        lexer.consumeWhileDigit();
    }
    return .{
        .position = .{
            .start = lexer.start.index,
            .end = lexer.index,
        },
        .type = .number,
    };
}
inline fn consumeWhileDigit(lexer: *Lexer) void {
    while (std.ascii.isDigit(lexer.peek())) {
        _ = lexer.consume();
    }
}

fn skipWhitespace(lexer: *Lexer) void {
    while (std.ascii.isWhitespace(lexer.peek())) {
        _ = lexer.consume();
    }
}

inline fn consume(lexer: *Lexer) u8 {
    return if (lexer.eof())
        0
    else blk: {
        defer lexer.index += 1;
        break :blk lexer.buffer[lexer.index];
    };
}

inline fn eof(lexer: Lexer) bool {
    return lexer.index >= lexer.buffer.len;
}

inline fn peek(lexer: Lexer) u8 {
    if (lexer.eof()) {
        return 0;
    }
    return lexer.buffer[lexer.index];
}

inline fn peekNext(lexer: Lexer) u8 {
    return if (lexer.index + 1 >= lexer.buffer.len)
        0
    else
        lexer.buffer[lexer.index];
}

inline fn expect(lexer: *Lexer, expected: u8) bool {
    if (lexer.peek() == expected) {
        _ = lexer.consume();
        return true;
    }
    return false;
}

inline fn currentLexeme(lexer: Lexer) []const u8 {
    return lexer.buffer[lexer.start.index..lexer.index];
}

inline fn invalidToken(lexer: Lexer) Token {
    return lexer.createToken(.invalid);
}

inline fn createToken(lexer: Lexer, ty: Token.Type) Token {
    return .{
        .position = .{
            .start = lexer.start.index,
            .end = lexer.index,
        },
        .type = ty,
    };
}

pub inline fn freeBuffer(lexer: *Lexer) void {
    lexer.allocator.free(lexer.buffer);
}

pub fn deinit(lexer: *Lexer) void {
    lexer.freeBuffer();
}
