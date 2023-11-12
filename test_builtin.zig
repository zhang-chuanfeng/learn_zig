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

//@This()

test "@This()" {
    var items = [_]i32{ 1, 2, 3, 4 };
    const list = List(i32){ .items = items[0..] };
    try expect(list.length() == 4);
}

fn List(comptime T: type) type {
    return struct {
        const Self = @This();
        items: []T,
        fn length(self: Self) usize {
            return self.items.len;
        }
    };
}
