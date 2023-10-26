const std = @import("std");

pub fn main() void {
    const Foo = struct {};
    std.debug.print("variable: {s}\n", .{@typeName(Foo)});
    std.debug.print("anonymous: {s}\n", .{@typeName(struct {})});
    std.debug.print("function: {s}\n", .{@typeName(List(i32))});
}

fn List(comptime T: type) type {
    return struct { x: T };
}

// struct type can be inferred

test "fully anonymous struct" {
    try dump(.{
        .int = 1234,
        .float = 12.34,
        .b = true,
        .s = "hi",
    });
}

const expect = @import("std").testing.expect;
fn dump(args: anytype) !void {
    try expect(args.int == 1234);
    try expect(args.float == 12.34);
    try expect(args.b);
    try expect(args.s[0] == 'h');
    try expect(args.s[1] == 'i');
}

// struct tuple
// anonymous structs
// without specifying field names

test "tuple" {
    const values = .{
        @as(u32, 1234),
        @as(f64, 12.34),
        true,
        "hi",
    } ++ .{false} ** 2;

    try expect(values[0] == 1234);
    try expect(values[4] == false);

    inline for (values, 0..) |v, i| {
        if (i != 2) continue;
        try expect(v);
    }
    try expect(values.len == 6);
    try expect(values.@"3"[0] == 'h');
    try expect(values[3][1] == 'i');
}
