const std = @import("std");
const expect = std.testing.expect;
const fmt = std.fmt;
const mem = std.mem;

test "using slices for strings" {
    const hello: []const u8 = "hello";
    const world: []const u8 = "世界";

    var all_together: [100]u8 = undefined;
    var start: usize = 0;
    const all_together_slice = all_together[start..];
    const hello_world = try fmt.bufPrint(all_together_slice, "{s} {s}", .{ hello, world });

    try expect(mem.eql(u8, hello_world, "hello 世界"));
}

// slice array
test "slice pointer" {
    var a: []u8 = undefined;
    try expect(@TypeOf(a) == []u8);
    var array: [10]u8 = undefined;
    const ptr = &array;
    try expect(@TypeOf(ptr) == *[10]u8);
    try expect(ptr.len == 10);

    var start: usize = 0;
    var end: usize = 5;
    const slice = ptr[start..end];
    try expect(slice.len == (end - start));
    try expect(@TypeOf(slice) == []u8);
    slice[2] = 3;

    const ptr2 = slice[2..3];
    try expect(ptr2.len == 1);
    try expect(ptr2[0] == 3);
    try expect(@TypeOf(ptr2) == *[1]u8);
}
