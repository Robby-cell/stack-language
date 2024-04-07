const std = @import("std");
const Runtime = @import("Runtime.zig");

const buffer =
    \\push 3 push 4 add print push 44.2 mul print pop
;

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var runtime = try Runtime.init(allocator, 256, buffer);
    defer runtime.deinit();

    try runtime.run();
}
