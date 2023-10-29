const expect = @import("std").testing.expect;

// while loop continue expression

test "while loop continue expression" {
    var i: usize = 0;
    while (i < 10) : (i += 1) {}
    try expect(i == 10);
}

test "while loop continue expression, more complicated" {
    var i: usize = 1;
    var j: usize = 1;
    while (i * j < 1000) : ({
        i *= 2;
        j *= 3;
    }) {
        const my_ij = i * j;
        try expect(my_ij < 2000);
    }
}

// else while
// break,return accepts a value parameter

test "while else" {
    try expect(rangeHasNumber(0, 10, 5));
    try expect(!rangeHasNumber(0, 10, 15));
}

fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;
    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

// labeled while
// when a while loop is labeled, it can be referenced from a break or
// continue from within a nested loop

test "nested break" {
    outer: while (true) {
        while (true) {
            break :outer;
        }
    }
}

test "nested continue" {
    var i: usize = 0;
    outer: while (i < 10) : (i += 1) {
        while (true) {
            continue :outer;
        }
    }
}

// while with optionals

test "while null capture" {
    var sum1: u32 = 0;
    number_left = 3;
    number_left = 3;
    while (eventuallyNullSequence()) |value| {
        sum1 += value;
    }
    try expect(sum1 == 3);

    var sum2: u32 = 0;
    number_left = 3;
    while (eventuallyNullSequence()) |value| {
        sum2 += value;
    } else {
        try expect(sum2 == 3);
    }
}

var number_left: u32 = undefined;
fn eventuallyNullSequence() ?u32 {
    return if (number_left == 0) null else blk: {
        number_left -= 1;
        break :blk number_left;
    };
}

// inline while
// compile time
test "inline while loop" {
    comptime var i = 0;
    var sum: usize = 0;
    inline while (i < 3) : (i += 1) {
        const T = switch (i) {
            0 => f32,
            1 => i8,
            2 => bool,
            else => unreachable,
        };
        sum += typeNameLength(T);
    }
    try expect(sum == 9);
}

fn typeNameLength(comptime T: type) usize {
    return @typeName(T).len;
}

// while with error unions
test "while error union capture" {
    var sum1: u32 = 0;
    number_left = 3;
    while (eventuallyErrorSequence()) |value| {
        sum1 += value;
    } else |err| {
        try expect(err == error.ReachedZero);
    }
}

fn eventuallyErrorSequence() anyerror!u32 {
    return if (number_left == 0) error.ReachedZero else blk: {
        number_left -= 1;
        break :blk number_left;
    };
}
