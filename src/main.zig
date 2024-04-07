const std = @import("std");
const Runtime = @import("Runtime.zig");
const zargs = @import("zargs");

const Options = struct {
    file: ?[]const u8 = null,

    pub const shorthands = .{
        .f = "file",
    };
};

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var opts = try zargs.currentProcParse(Options, allocator);
    defer opts.deinit();

    if (opts.options.file) |file| {
        var runtime = try Runtime.fromFile(file, allocator);
        defer runtime.deinit();
        try runtime.run();
    } else {
        // repl
    }
}
