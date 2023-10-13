const std = @import("std");
const expect = std.testing.expect;
const minInt = std.math.minInt;
const maxInt = std.math.maxInt;

test "wrapping test" {
    const x: i32 = maxInt(i32);
    var min_val = x +% 1;
    try expect(min_val == minInt(i32));
    min_val -|= 1;
    try expect(min_val == minInt(i32));
    var max_val = min_val -% 1;
    try expect(max_val == maxInt(i32));
    max_val +|= 1;
    try expect(max_val == maxInt(i32));
}
