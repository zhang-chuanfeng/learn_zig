const std = @import("std");
const expect = std.testing.expect;

test "turn HashMap into a set with void" {
    var map = std.AutoHashMap(i32, void).init(std.testing.allocator);
    defer map.deinit();

    try map.put(1, {});
    try map.put(2, {});

    try expect(map.contains(2));
    try expect(!map.contains(3));

    _ = map.remove(2);
    try expect(!map.contains(2));
}

// void has a known size of 0 bytes, and anyopaque has an
// unknown, but non-zero, size.

// usingnamespace
test "using std namespace" {
    const S = struct {
        usingnamespace @import("std");
    };
    try S.testing.expect(true);
}

// pub usingnamespace @cImport({
//     @cInclude("xsdf");
//     @cDefine("TJKK", "");
// });
