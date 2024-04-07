const std = @import("std");
const Allocator = std.mem.Allocator;

const Lexer = @import("Lexer.zig");
const Token = @import("Token.zig");

const Runtime = @This();

const Value = f64;

allocator: Allocator,
stack: []Value,
stack_ptr: u32,
lexer: Lexer,
current_token: Token,

pub fn init(allocator: Allocator, stack_size: u32, buffer: []const u8) !Runtime {
    var runtime: Runtime = .{
        .allocator = allocator,
        .stack = try allocator.alloc(Value, stack_size),
        .stack_ptr = 0,
        .lexer = Lexer.init(buffer),
        .current_token = undefined,
    };
    runtime.nextToken();
    return runtime;
}

fn nextToken(runtime: *Runtime) void {
    runtime.current_token = runtime.lexer.nextToken();
}

pub fn run(runtime: *Runtime) !void {
    while (runtime.current_token.type != .eof) {
        try runtime.handleCurrentToken();
    }
}

inline fn handleCurrentToken(runtime: *Runtime) !void {
    switch (runtime.current_token.type) {
        .add, .sub, .mul, .div => try runtime.handleOperation(),

        .print => try runtime.print(),
        .push => |ty| {
            runtime.nextToken();

            switch (runtime.current_token.type) {
                .number => if (ty == .push) {
                    _ = try runtime.push(try runtime.valueFromCurrentToken());
                },
                .pop => {
                    const value = try runtime.pop();
                    _ = try runtime.push(value);
                },
                .invalid => return error.InvalidToken,
                else => return error.InvalidSyntax,
            }
            runtime.nextToken();
        },
        .pop => {
            runtime.nextToken();
            _ = try runtime.pop();
        },

        .invalid => return error.InvalidToken,
        .number => return error.InvalidSyntax,

        .eof => {},
    }
}

inline fn handleOperation(runtime: *Runtime) !void {
    const op = runtime.current_token.type;

    const b = try runtime.pop();
    const a = try runtime.pop();

    const result = switch (op) {
        .add => a + b,
        .sub => a - b,
        .mul => a * b,
        .div => a / b,
        else => unreachable,
    };

    _ = try runtime.push(result);
    runtime.nextToken();
}

inline fn print(runtime: *Runtime) !void {
    const value = try runtime.peek(0);
    std.debug.print("{}\n", .{value});

    runtime.nextToken();
}

pub fn deinit(runtime: *Runtime) void {
    runtime.allocator.free(runtime.stack);
}

pub fn push(runtime: *Runtime, value: Value) !u32 {
    if (runtime.stack_ptr >= runtime.stack.len) {
        return error.StackOverflow;
    }
    defer runtime.stack_ptr += 1;
    runtime.stack[runtime.stack_ptr] = value;
    return runtime.stack_ptr;
}

pub fn peek(runtime: Runtime, index: u32) !Value {
    if (index > runtime.stack_ptr) {
        return error.InvalidMemoryAccess;
    }
    return runtime.stack[runtime.stack_ptr - (index + 1)];
}

pub fn pop(runtime: *Runtime) !Value {
    if (runtime.stack_ptr == 0) {
        return error.EmptyStackAttemptedPop;
    }
    runtime.stack_ptr -= 1;
    return runtime.stack[runtime.stack_ptr];
}

inline fn valueFromCurrentToken(runtime: Runtime) !Value {
    const current_position = runtime.current_token.position;
    const buf = runtime.lexer.buffer[current_position.start..current_position.end];

    return std.fmt.parseFloat(f64, buf);
}
