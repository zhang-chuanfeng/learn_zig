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
        print("1 \n", .{});
    }
    defer {
        print("2 \n", .{});
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

// Inside a defer expression the return statement is not allowed

fn deferInvalidExample() !void {
    defer {
        // return error.DeferError;
    }
    return error.DeferError;
}

// The errdefer keyword is similar to derfer, but will only execute if
// the scope returns with an error

// This is especially useful in allowing a function to clean up properly
// on error, and replaces goto error handling tacting tactics as seen in c.

fn deferErrorExample(is_error: bool) !void {
    print("\nstart of function\n", .{});

    // This will always be excuted on exit
    defer {
        print("end of function\n", .{});
    }

    errdefer {
        print("encountered an error!\n", .{});
    }

    if (is_error) {
        return error.DeferError;
    }
}

// The errdefer keyword also supports an alternative syntax to capture the
// generated error.
// This is useful for printing an additional error message during clean up.
fn deferErrorCaptureExample() !void {
    errdefer |err| {
        std.debug.print("the error is {s}\n", .{@errorName(err)});
    }
    return error.DeferError;
}

test "errdefer unwinding" {
    deferErrorExample(false) catch {};
    deferErrorExample(true) catch {};
    deferErrorCaptureExample() catch {};
}
