const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;

test "using an allocator" {
    var buffer: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    const result = try concat(allocator, "foo", "bar");
    try expect(std.mem.eql(u8, "foobar", result));
}

fn concat(allocator: Allocator, a: []const u8, b: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, a.len + b.len);
    std.mem.copy(u8, result, a);
    std.mem.copy(u8, result[a.len..], b);
    return result;
}

// Is the maximum number of bytes that you will need bounded by a number known at compile?
// use std.heap.FixedBufferAllocator or std.heap.ThreadSafeFixedBufferAllocator

// like command line application
// it would make sense to free everything at once at the end
// use ArenaAllocator

// std.heap.GeneralPurposeAllocator

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const ptr = try allocator.create(i32);
    std.debug.print("ptr={*}\n", .{ptr});
}
