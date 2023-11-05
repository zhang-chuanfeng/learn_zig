test "type coercion - variable declaration" {
    var a: u8 = 1;
    var b: u16 = a;
    _ = b;
}

test "type coercion - function call" {
    var a: u8 = 1;
    foo(a);
}

fn foo(b: u16) void {
    _ = b;
}

test "type coerion - @as builtin" {
    var a: u8 = 1;
    var b = @as(u16, a);
    _ = b;
}

// const - non-const to const is allowed
// volatile - non-volatile to volatile is allowed
// align - bigger to smaller alignment is allowed
// error-set to supersets is allowed

// pointers coerce to const optional pointers
const std = @import("std");
const expect = std.testing.expect;
const mem = std.mem;

test "cast *[1][*]const u8 to [*]const ?[*]const u8" {
    const window_name = [1][*]const u8{"window name"};
    const x: [*]const ?[*]const u8 = &window_name;
    try expect(mem.eql(u8, mem.sliceTo(@as([*:0]const u8, @ptrCast(x[0].?)), 0), "window name"));
}

// integer widening

test "integer widening" {
    var a: u8 = 250;
    var b: u16 = a;
    var c: u32 = b;
    var d: u64 = c;
    var e: u64 = d;
    var f: u128 = e;
    try expect(f == a);
}

test "implicit unsigned interger to signed interger" {
    var a: u8 = 250;
    var b: i16 = a;
    try expect(b == 250);
}

test "float widening" {
    var a: f16 = 12.34;
    var b: f32 = a;
    var c: f64 = b;
    var d: f128 = c;
    try expect(d == a);
}

// type coercion: Slice,Arrays and Pointers
// You can assign constant pointers to arrays to a slice with const
// modifier on the element type. Useful in particular for string literals.
test "*const [N]T to []const T" {
    var x1: []const u8 = "hello";
    var x2: []const u8 = &[5]u8{ 'h', 'e', 'l', 'l', 111 };
    try expect(mem.eql(u8, x1, x2));

    var y: []const f32 = &[2]f32{ 1.2, 3.4 };
    try expect(y[0] == 1.2);
}

// Likewise, it works when the destination type is an error union.
test "*const [N]T to E![]const T" {
    var x1: anyerror![]const u8 = "hello";
    var x2: anyerror![]const u8 = &[5]u8{ 'h', 'e', 'l', 'l', 111 };
    try expect(mem.eql(u8, try x1, try x2));

    var y: anyerror![]const f32 = &[2]f32{ 1.2, 3.4 };
    try expect((try y)[0] == 1.2);
}

//Likewise, it works when the destination type is an optional.
test "*const [N]T to ?[]const T" {
    var x1: ?[]const u8 = "hello";
    var x2: ?[]const u8 = &[5]u8{ 'h', 'e', 'l', 'l', 111 };
    try expect(mem.eql(u8, x1.?, x2.?));

    var y: ?[]const f32 = &[2]f32{ 1.2, 3.4 };
    try expect(y.?[0] == 1.2);
}

// In this cast, the array length becomes the slice length.
test "*[]T to []T" {
    var buf: [5]u8 = "hello".*;
    const x: []u8 = &buf;
    try expect(mem.eql(u8, x, "hello"));

    const buf2 = [2]f32{ 1.2, 3.4 };
    const x2: []const f32 = &buf2;

    try expect(mem.eql(f32, x2, &[2]f32{ 1.2, 3.4 }));
}

// single-item pointers to arrays can be coerced to many-item pointers
test "*[N]T to [*]T" {
    var buf: [5]u8 = "hello".*;
    const x: [*]u8 = &buf;
    try expect(x[4] == 'o');
}

// Likewise, it works when the destination type is an optional.
test "*[N]T to ?[*]T" {
    var buf: [5]u8 = "hello".*;
    const x: ?[*]u8 = &buf;
    try expect(x.?[4] == 'o');
}

// Single-item pointers can be cast to len-1 single-item arrays.
test "*T to *[1]T" {
    var x: i32 = 1234;
    const y: *[1]i32 = &x;
    const z: [*]i32 = y;
    try expect(z[0] == 1234);
}

// coerion optionals
test "coerce to optionals" {
    const x: ?i32 = 1234;
    const y: ?i32 = null;

    try expect(x.? == 1234);
    try expect(y == null);
}

test "coerce to optionals wrapped in error union" {
    const x: anyerror!?i32 = 1234;
    const y: anyerror!?i32 = null;

    try expect((try x).? == 1234);
    try expect((try y) == null);
}

test "coering large interger type to smaller one value is comptime-known to fit" {
    const x: u64 = 255;
    const y: u8 = x;
    try expect(y == 255);
}

const E = enum {
    one,
    two,
    three,
};

const U = union(E) {
    one: i32,
    two: f32,
    three,
};

const U2 = union(enum) {
    a: void,
    b: f32,

    fn tag(self: U2) usize {
        switch (self) {
            .a => return 1,
            .b => return 2,
        }
    }
};

test "coerion between unions and enums" {
    var u = U{ .two = 12.34 };
    var e: E = u; // coerce union to enum
    try expect(e == E.two);

    const three = E.three;
    var u_2: U = three; // coerce enum to union
    try expect(u_2 == E.three);

    var u_3: U = .three;
    try expect(u_3 == E.three);

    var u_4: U2 = .a; // coerce enum literal to union with inferred enum tag type.
    try expect(u_4.tag() == 1);

    // The following example is invalid.
    // error: coerion from enum '@TypeOf(.enum_literal)' to union 'test_coerce_unions_enum.U2' must
    // initialize 'f32' field 'b'
    // var u_5:U2 = .b;
    // try expect(u_5.tag() == 2);
}

// type coercion: Tuples to arrays
// tupels can be coerced to arrays, if all of the fields have the same type.
const Tuple = struct { u8, u8 };
test "coercion from homogenous tuple to array" {
    const tuple: Tuple = .{ 5, 6 };
    const array: [2]u8 = tuple;
    _ = array;
}

// explicit casts
// Builtin functions
// @bitCast .... @ptrCast ...

// Peer Type Resolution
// occurs in these places
// swith expression
// if expression
// while / for expression
// Multipile break statements in a block
// Some binary operations

test "peer resolve int widening" {
    var a: i8 = 12;
    var b: i16 = 34;
    var c = a + b;
    try expect(c == 46);
    try expect(@TypeOf(c) == i16);
}

test "peer resolve arrays of different size to const slice" {
    try expect(mem.eql(u8, booToStr(true), "true"));
    try expect(mem.eql(u8, booToStr(false), "false"));
    try comptime expect(mem.eql(u8, booToStr(true), "true"));
    try comptime expect(mem.eql(u8, booToStr(false), "false"));
}
fn booToStr(b: bool) []const u8 {
    return if (b) "true" else "false";
}

test "peer resolve array and const slice" {
    try testPeerResolveArrayConstSlice(true);
    try comptime testPeerResolveArrayConstSlice(true);
}
fn testPeerResolveArrayConstSlice(b: bool) !void {
    const value1 = if (b) "aoeu" else @as([]const u8, "zz");
    const value2 = if (b) @as([]const u8, "zz") else "aoeu";

    try expect(mem.eql(u8, value1, "aoeu"));
    try expect(mem.eql(u8, value2, "zz"));
}

test "peer type resolution: ?T and T" {
    try expect(peerTypeTAndOptionalT(true, false) == 0);
    try expect(peerTypeTAndOptionalT(false, false) == 3);

    comptime {
        try expect(peerTypeTAndOptionalT(true, false) == 0);
        try expect(peerTypeTAndOptionalT(false, false) == 3);
    }
}
fn peerTypeTAndOptionalT(c: bool, b: bool) ?usize {
    if (c) {
        return if (b) null else @as(usize, 0);
    }
    return @as(usize, 3);
}

test "peer type resolution:*[0]u8 and []const u8" {
    try expect(peerTypeEmptyArrayAndSlice(true, "hi").len == 0);
    try expect(peerTypeEmptyArrayAndSlice(false, "hi").len == 1);
    comptime {
        try expect(peerTypeEmptyArrayAndSlice(true, "hi").len == 0);
        try expect(peerTypeEmptyArrayAndSlice(false, "hi").len == 1);
    }
}

fn peerTypeEmptyArrayAndSlice(a: bool, slice: []const u8) []const u8 {
    if (a) {
        return &[_]u8{};
    }
    return slice[0..1];
}

test "peer type resolution: *[0]u8, []const u8, and anyerror![]u8" {
    {
        var data = "hi".*;
        const slice = data[0..];
        try expect((try peerTypeEmptyArrayAndSliceAndError(true, slice)).len == 0);
        try expect((try peerTypeEmptyArrayAndSliceAndError(false, slice)).len == 1);
    }
    comptime {
        var data = "hi".*;
        const slice = data[0..];
        try expect((try peerTypeEmptyArrayAndSliceAndError(true, slice)).len == 0);
        try expect((try peerTypeEmptyArrayAndSliceAndError(false, slice)).len == 1);
    }
}
fn peerTypeEmptyArrayAndSliceAndError(a: bool, slice: []u8) anyerror![]u8 {
    if (a) {
        return &[_]u8{};
    }
    return slice[0..1];
}

test "peer type resolution: *const T and ?*T" {
    const a: *const usize = @ptrFromInt(0x123456780);
    const b: ?*usize = @ptrFromInt(0x123456780);
    try expect(a == b);
    try expect(b == a);
}
