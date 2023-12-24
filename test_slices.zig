const std = @import("std");
const expect = std.testing.expect;
const fmt = std.fmt;
const mem = std.mem;

test "using slices for strings" {
    const hello: []const u8 = "hello";
    const world: []const u8 = "世界";

    var all_together: [100]u8 = undefined;
    const start: usize = 0;
    const all_together_slice = all_together[start..];
    const hello_world = try fmt.bufPrint(all_together_slice, "{s} {s}", .{ hello, world });

    try expect(mem.eql(u8, hello_world, "hello 世界"));
}

// slice array
test "slice pointer" {
    const a: []u8 = undefined;
    try expect(@TypeOf(a) == []u8);
    var array: [10]u8 = undefined;
    const ptr = &array;
    try expect(@TypeOf(ptr) == *[10]u8);
    try expect(ptr.len == 10);

    var start: usize = 0;
    start = 0;
    var end: usize = 5;
    end = 5;
    const slice = ptr[start..end];
    try expect(slice.len == (end - start));
    try expect(@TypeOf(slice) == []u8);
    slice[2] = 3;

    const ptr2 = slice[2..3];
    try expect(ptr2.len == 1);
    try expect(ptr2[0] == 3);
    try expect(@TypeOf(ptr2) == *[1]u8);
}

test "null terminated slice" {
    const slice: [:0]const u8 = "hello";
    try expect(slice.len == 5);
    // Sentinel-terminated slices allow elment access to the len index
    try expect(slice[5] == 0);
}

test "sentinel mismatch" {
    var array = [_]u8{ 3, 2, 1, 0 };

    const runtime_length: usize = 2;
    const slice = array[0..runtime_length :1];
    // const slice = array[0..runtime_length :0]; // panic
    _ = slice;
}
