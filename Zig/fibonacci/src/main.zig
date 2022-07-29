const std = @import("std");

fn fibonacci(i: u64) u64 {
    if (i <= 1) return i;
    return fibonacci(i - 1) + fibonacci(i - 2);
}

fn print_fibonacci(w: anytype, s: []const u8) !void {
    const i = try std.fmt.parseUnsigned(u64, s, 10);
    try w.print("Fibonacci sequence number at index {d} is {d}\n", .{i, fibonacci(i)});
}

pub fn main() !void {
    const alloc: std.mem.Allocator = std.heap.page_allocator;

    var args = try std.process.argsAlloc(alloc);
    defer alloc.free(args);

    const stdout = std.io.getStdOut();
    defer stdout.close();

    const out = stdout.writer();
    const indexes = args[1..];
    if (indexes.len > 0) {
        for (indexes) |arg| {
            try print_fibonacci(out, arg);
        }
    } else {
        const stdin = std.io.getStdIn();
        defer stdin.close();

        try out.print("No arguments specified, please specify Fibonacci sequence index: \n", .{});
        var buf: [19]u8 = undefined;
        if (try stdin.reader().readUntilDelimiterOrEof(&buf, '\n')) |arg| {
            try print_fibonacci(out, arg);
        } else {
            std.debug.print("failed to read from stdin", .{});
            std.process.exit(1);
        }
    }
}
