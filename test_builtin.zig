// @src
const std = @import("std");
const expect = std.testing.expect;

test "@src" {
    try doTheTest();
}

fn doTheTest() !void {
    const src = @src();

    try expect(src.line == 10);
    try expect(src.column == 17);
    try expect(std.mem.eql(u8, src.fn_name, "doTheTest"));
    try expect(std.mem.eql(u8, src.file, "test_builtin.zig"));
}
