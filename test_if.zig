const expect = @import("std").testing.expect;

test "if expression" {
    const a: u32 = 5;
    const b: u32 = 4;
    const result = if (a != b) 47 else 3089;
    try expect(result == 47);
}

test "if boolen" {
    const a: u32 = 5;
    const b: u32 = 4;

    if (a != b) {
        try expect(true);
    } else if (a == 9) {
        unreachable;
    } else {
        unreachable;
    }
}

test "if optional" {
    const a: ?u32 = 0;
    if (a) |value| {
        try expect(value == 0);
    } else {
        unreachable;
    }

    const b: ?u32 = null;
    if (b) |_| {
        unreachable;
    } else {
        try expect(true);
    }

    if (a) |value| {
        try expect(value == 0);
    }

    if (b == null) {
        try expect(true);
    }

    var c: ?u32 = 3;
    if (c) |*value| {
        value.* = 2;
    }

    if (c) |value| {
        try expect(value == 2);
    } else {
        unreachable;
    }
}

test "if error union" {
    const a: anyerror!u32 = 0;
    if (a) |value| {
        try expect(value == 0);
    } else |err| {
        _ = err;
        unreachable;
    }

    const b: anyerror!u32 = error.BadValue;
    if (b) |value| {
        _ = value;
        unreachable;
    } else |err| {
        try expect(err == error.BadValue);
    }

    if (a) |value| {
        try expect(value == 0);
    } else |_| {}

    if (b) |_| {} else |err| {
        try expect(err == error.BadValue);
    }

    var c: anyerror!u32 = 3;
    if (c) |*value| {
        value.* = 9;
    } else |_| {
        unreachable;
    }

    if (c) |value| {
        try expect(value == 9);
    } else |_| {
        unreachable;
    }
}

test "if error union with optional" {
    const a: anyerror!?u32 = 0;
    if (a) |opaque_value| {
        try expect(opaque_value.? == 0);
    } else |_| {
        unreachable;
    }

    const b: anyerror!?u32 = null;
    if (b) |opaque_value| {
        try expect(opaque_value.? == null);
    } else |_| {
        unreachable;
    }

    const c: anyerror!?u32 = error.BadValue;
    if (c) |opaque_value| {
        _ = opaque_value;
        unreachable;
    } else |err| {
        try expect(err == error.BadValue);
    }
}
