const std = @import("std");
const expect = std.testing.expect;

test "sorting" {
    var data = [_]u8{ 10, 240, 0, 0, 10, 5 };
    std.mem.sort(u8, &data, {}, comptime std.sort.asc(u8));
    try expect(std.mem.eql(u8, &data, &[_]u8{ 0, 0, 5, 10, 10, 240 }));
    std.mem.sort(u8, &data, {}, comptime std.sort.desc(u8));
    try expect(std.mem.eql(u8, &data, &[_]u8{ 240, 10, 10, 5, 0, 0 }));
}
