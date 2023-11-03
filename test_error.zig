const std = @import("std");
const expect = std.testing.expect;

const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{
    OutOfMemory,
};

// coerce error subset to superset
test "coerce subset to superset" {
    const err = foo(AllocationError.OutOfMemory);
    try expect(err == FileOpenError.OutOfMemory);
}

fn foo(err: AllocationError) FileOpenError {
    return err;
}

// you cannot coerce an error from a superset to a subset

// single value error set shortcut
const err1 = error.FileNotFound1;
// const err1 = (error {FileNotFound}).FileNotFound;

// error parsing u64
const maxInt = std.math.maxInt;

pub fn parseU64(buf: []const u8, radix: u8) !u64 {
    var x: u64 = 0;
    for (buf) |c| {
        const digit = charToDigit(c);
        if (digit >= radix) {
            return error.InvalidChar;
        }
        // x *= radix
        var ov = @mulWithOverflow(x, radix);
        if (ov[1] != 0) return error.OverFlow;

        // x += digit
        ov = @addWithOverflow(ov[0], digit);
        if (ov[1] != 0) return error.OverFlow;
        x = ov[0];
    }
    return x;
}

fn charToDigit(c: u8) u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'A'...'Z' => c - 'A' + 10,
        'a'...'z' => c - 'a' + 10,
        else => maxInt(u8),
    };
}

test "parse u64" {
    const result = try parseU64("1234", 10);
    try expect(result == 1234);
}

fn doAThing(str: []u8) void {
    const number = parseU64(str, 10) catch 13;
    _ = number;
}

fn doAThing2(str: []u8) void {
    const number = parseU64(str, 10) catch blk: {
        // do things
        break :blk 13;
    };
    _ = number;
}
// try
fn doAThing3(str: []u8) !void {
    const number = parseU64(str, 10) catch |err| return err;
    _ = number;
}

fn doAThing4(str: []u8) !void {
    const number = try parseU64(str, 10);
    _ = number;
    // const number = parseU64("1234", 10) catch unreachable;
}

fn doAThing5(str: []u8) void {
    if (parseU64(str, 10)) |number| {
        _ = number;
    } else |err| switch (err) {
        error.Overflow => {
            // handle overflow...
        },
        err.InvalidChar => unreachable,
    }
}

fn doAThing6(str: []u8) error{InvalidChar}!void {
    if (parseU64(str, 10)) |number| {
        _ = number;
    } else |err| switch (err) {
        error.Overflow => {
            //
        },
        else => |leftover_err| return leftover_err,
    }
}

fn doAThing7(str: []u8) error{InvalidChar}!void {
    if (parseU64(str, 10)) |number| {
        _ = number;
    } else |err| switch (err) {
        error.Overflow => {
            //
        },
        else => |_| {
            //
        },
    }
}

//errdefer
const Allocator = std.mem.Allocator;
const Foo = struct {
    data: u32,
};

fn tryToAllocateFoo(allocator: Allocator) !*Foo {
    return allocator.create(Foo);
}

fn deallocateFoo(allocator: Allocator, fooo: *Foo) void {
    allocator.destroy(fooo);
}

fn getFooData() !u32 {
    return 666;
}

fn createFoo(allocator: Allocator, param: i32) !*Foo {
    const fooo = getFoo: {
        var fooo = try tryToAllocateFoo(allocator);
        errdefer deallocateFoo(allocator, fooo);

        fooo.data = try getFooData();
        break :getFoo fooo;
    };
    errdefer deallocateFoo(allocator, fooo);

    if (param > 1337) return error.InvalidParam;
    return fooo;
}

test "createFoo" {
    try std.testing.expectError(error.InvalidParam, createFoo(std.testing.allocator, 2468));
}

const Foo2 = struct {
    data: *u32,
};

fn genFoo2s(allocator: Allocator, num: usize) ![]Foo2 {
    var foos = try allocator.alloc(Foo2, num);
    errdefer allocator.free(foos);

    var num_allocated: usize = 0;
    errdefer for (foos[0..num_allocated]) |foo2| {
        allocator.destroy(foo2.data);
    };
    for (foos, 0..) |*foo2, i| {
        foo2.data = try allocator.create(u32);
        num_allocated += 1;

        if (i > 3) return error.TooManyFoos;
        foo2.data.* = try getFooData();
    }
    return foos;
}

test "genFoos" {
    try std.testing.expectError(error.TooManyFoos, genFoo2s(std.testing.allocator, 5));
}

// error union reflection
test "error union" {
    var foo3: anyerror!i32 = undefined;
    foo3 = 1234;
    foo3 = error.SomeError;

    // use compile-time reflection to access the payload type of an error union
    try comptime expect(@typeInfo(@TypeOf(foo3)).ErrorUnion.payload == i32);

    // use compile-time reflection to access the error set type of an error union
    try comptime expect(@typeInfo(@TypeOf(foo3)).ErrorUnion.error_set == anyerror);
}

// merging error sets
const A = error{
    NotDir,

    /// A doc comment
    PathNotFound,
};
const B = error{
    OutOfMemory,

    /// B doc comment
    PathNotFound,
};

const C = A || B;
fn foo4() C!void {
    return error.NotDir;
}

test "merge error set" {
    if (foo4()) {} else |err| switch (err) {
        error.OutOfMemory => @panic("unexpected"),
        error.PathNotFound => @panic("unexpected"),
        error.NotDir => {},
    }
}
