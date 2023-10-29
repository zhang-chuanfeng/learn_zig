const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

// defer will execute an expression at the end of the current scope.
fn deferExample() !usize {
    var a: usize = 1;
    {
        defer a = 2;
        a = 1;
    }
    try expect(a == 2);
    a = 5;
    return a;
}

test "defer basic" {
    try expect(try deferExample() == 5);
}

// if multiple defer statements are specified, they will be execute in
// the reverse order they were run.
fn deferUnwindExample() void {
    defer {
        print("1 ", .{});
    }
    defer {
        print("2 ", .{});
    }
    if (false) {
        // derfers are not run if they are never executed.
        defer {
            print("3 ", .{});
        }
    }
}

test "defer unwinding" {
    deferUnwindExample();
}
