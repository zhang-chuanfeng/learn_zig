const std = @import("std");

test "container level variables" {
    try std.testing.expect(x == 46);
    try std.testing.expect(y == 56);
}

var y: i32 = add(10, x);
const x = add(12, 34); // comptime

fn add(a: i32, b: i32) i32 {
    return a + b;
}

const S = struct {
    var x: i32 = 1234;
};

fn foo() i32 {
    S.x += 1;
    return S.x;
}

test "namespaced container level variable" {
    try std.testing.expect(foo() == 1235);
    try std.testing.expect(foo() == 1236);
}

fn foo2() i32 {
    const SS = struct {
        var x: i32 = 1234;
    };
    SS.x += 1;
    return SS.x;
}

test "static local variable" {
    try std.testing.expect(foo2() == 1235);
    try std.testing.expect(foo2() == 1236);
}
