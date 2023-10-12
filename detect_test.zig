const std = @import("std");
const builtin = @import("builtin");
const except = std.testing.expect;

test "builtin.is_test" {
    try except(isATest());
}

fn isATest() bool {
    return builtin.is_test;
}
