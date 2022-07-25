const std = @import("std");

fn fibonacci(i: u64) u64 {
    if (i <= 1) return i;
    return fibonacci(i - 1) + fibonacci(i - 2);
}

pub fn main() !void {
    const alloc: std.mem.Allocator = std.heap.page_allocator;

    var args = try std.process.argsAlloc(alloc);
    defer alloc.free(args);

    const stdout = std.io.getStdOut().writer();
    for (args[1..]) |arg| {
        const i = try std.fmt.parseUnsigned(u64, arg, 10);
        try stdout.print("Fibonacci sequence number at index {d} is {d}\n", .{i, fibonacci(i)});
    }
}
