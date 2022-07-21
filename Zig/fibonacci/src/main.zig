const std = @import("std");

fn fibonacci(index: u32) u32 {
    if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var x: u32 = 7;

    try stdout.print("fibonacci of {d} ", .{x});
    try stdout.print("is: {d} \n ", .{fibonacci(x)}  );
}
