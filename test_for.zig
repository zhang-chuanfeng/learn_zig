const expect = @import("std").testing.expect;

test "for basic" {
    const items = [_]i32{ 4, 5, 3, 4, 0 };
    var sum: i32 = 0;

    // for loops iterate over slices and arrays
    for (items) |value| {
        // break and continue are supported
        if (value == 0) {
            continue;
        }
        sum += value;
    }
    try expect(sum == 16);

    // to iterate over a portion of a slice, reslice
    for (items[0..1]) |value| {
        sum += value;
    }
    try expect(sum == 20);

    // to access the index of iteration, specify a second condition as well
    // as a second capture value.
    var sum2: i32 = 0;
    for (items, 0..) |_, i| {
        try expect(@TypeOf(i) == usize);
        sum2 += @as(i32, @intCast(i));
    }
    try expect(sum2 == 10);

    // to iterate over consecutive intergers, use the range syntax.
    // unbounded range is always a compile error.
    var sum3: usize = 0;
    for (0..5) |i| {
        sum3 += i;
    }
    try expect(sum3 == 10);
}

test "multi object for" {
    const items = [_]usize{ 1, 2, 3 };
    const items2 = [_]usize{ 4, 5, 6 };
    var count: usize = 0;

    for (items, items2) |i, j| {
        count += i + j;
    }
    try expect(count == 21);
}

test "for reference" {
    var items = [_]i32{ 3, 4, 2 };

    // Iterate over the slice reference by
    // specifing that the capture value is a pointer.
    for (&items) |*value| {
        value.* += 1;
    }
    try expect(items[0] == 4);
    try expect(items[1] == 5);
    try expect(items[2] == 3);
}

test "for else" {
    var items = [_]?i32{ 3, 4, null, 5 };

    // for loops can also be used as expressions.
    // similar to while loops, when you break from a for loop, the else branch is
    // not evaluated.
    var sum: i32 = 0;
    const result = for (items) |value| {
        if (value != null) {
            sum += value.?;
        }
    } else blk: {
        try expect(sum == 12);
        break :blk sum;
    };
    try expect(result == 12);
}
