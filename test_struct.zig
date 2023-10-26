// Zig gives no guarantes about the order of fields and
// the size of the struct but the fields are guranteed to
// be ABI-aligned.

const Point = struct {
    x: f32,
    y: f32,
};

// Maybe we want to pass it to OpenGL so we want to be
// particular about how the bytes are arranged.
const Point2 = packed struct {
    x: f32,
    y: f32,
};

const p = Point{
    .x = 0.12,
    .y = 0.34,
};

var p2 = Point{
    .x = 0.12,
    .y = undefined,
};

// Structs can have methods
// Struct methods are not special, they are only namespaced
// functions that you can call with dot syntax.
const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};

const expect = @import("std").testing.expect;
test "dot product" {
    const v1 = Vec3.init(1.0, 0.0, 0.0);
    const v2 = Vec3.init(0.0, 1.0, 0.0);
    try expect(v1.dot(v2) == 0.0);
    try expect(Vec3.dot(v1, v2) == 0.0);
}

const Empty = struct {
    pub const PI = 3.14;
};

test "struct namespaced variable" {
    try expect(Empty.PI == 3.14);
    try expect(@sizeOf(Empty) == 0);

    const does_nothing = Empty{};
    _ = does_nothing;
}
// struct field order is determined by the compiler optimal performance.
// however, you can still calculate a struct base pointer given a field pointer.
fn setYBasedOnX(x: *f32, y: f32) void {
    const point = @fieldParentPtr(Point, "x", x);
    point.y = y;
}

test "field parent pointer" {
    var point = Point{
        .x = 0.1234,
        .y = 0.5678,
    };
    setYBasedOnX(&point.x, 0.9);
    try expect(point.y == 0.9);
}

// function return struct
fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: T,
        };
        first: ?*Node,
        last: ?*Node,
        len: usize,
    };
}

test "linked list" {
    try expect(LinkedList(i32) == LinkedList(i32));

    var list = LinkedList(i32){
        .first = null,
        .last = null,
        .len = 0,
    };
    try expect(list.len == 0);

    const ListOfInts = LinkedList(i32);
    try expect(ListOfInts == LinkedList(i32));

    var node = ListOfInts.Node{
        .prev = null,
        .next = null,
        .data = 1234,
    };
    var list2 = ListOfInts{
        .first = &node,
        .last = &node,
        .len = 1,
    };
    try expect(list2.first.?.data == 1234);
    // instead of try expect(list2.first.?.*.data == 1234);
}

// struct default field values
const Foo = struct { a: i32 = 1234, b: i32 };

test "default struct initialization fields" {
    const x = Foo{
        .b = 5,
    };
    if (x.a + x.b != 1239) {
        @compileError("it's even comptime-known!");
    }
}

// extern struct
// This kind of struct should only be used for compatibility with the C ABI.

// packed struct
// packed structs have guaranteed in-memory layout.
const std = @import("std");
const native_endian = @import("builtin").target.cpu.arch.endian();
const Full = packed struct {
    number: u16,
};

const Divided = packed struct {
    half1: u8,
    quarter3: u4,
    quarter4: u4,
};

test "@bitCast between packed structs" {
    try doTheTest();
    try comptime doTheTest();
}

fn doTheTest() !void {
    try expect(@sizeOf(Full) == 2);
    try expect(@sizeOf(Divided) == 2);
    var full = Full{ .number = 0x1234 };
    var divided: Divided = @bitCast(full);
    try expect(divided.half1 == 0x34);
    try expect(divided.quarter3 == 0x2);
    try expect(divided.quarter4 == 0x1);

    var ordered: [2]u8 = @bitCast(full);
    switch (native_endian) {
        .Big => {
            try expect(ordered[0] == 0x12);
            try expect(ordered[1] == 0x34);
        },
        .Little => {
            // std.debug.print("little\n", .{});
            try expect(ordered[0] == 0x34);
            try expect(ordered[1] == 0x12);
        },
    }
}

// non-byte_aligned_field
const BitField = packed struct {
    a: u3,
    b: u3,
    c: u2,
};

var foo = BitField{
    .a = 1,
    .b = 2,
    .c = 3,
};

test "pointer to non-byte-aligned field" {
    const ptr = &foo.b;
    try expect(ptr.* == 2);
}

test "pointer to non-bit-aligned field" {
    //try expect(bar(&foo.b) == 2);
}

// x: ABI aligned pointer
fn bar(x: *const u3) u3 {
    return x.*;
}

test "pointers of sub-byte-aligned fields share address" {
    try expect(@intFromPtr(&foo.a) == @intFromPtr(&foo.b));
    try expect(@intFromPtr(&foo.a) == @intFromPtr(&foo.c));

    // bitOffsetOf
    // offsetOf
    try expect(@bitOffsetOf(BitField, "a") == 0);
    try expect(@bitOffsetOf(BitField, "b") == 3);
    try expect(@bitOffsetOf(BitField, "c") == 6);

    try expect(@offsetOf(BitField, "a") == 0);
    try expect(@offsetOf(BitField, "b") == 0);
    try expect(@offsetOf(BitField, "c") == 0);
}

// overaligned packed struct
const S = packed struct {
    a: u32,
    b: u32,
};

test "overaligned pointer to packed struce" {
    var foo1: S align(4) = .{ .a = 1, .b = 2 };
    const ptr: *align(4) S = &foo1;
    const ptr_to_b: *u32 = &ptr.b;
    try expect(ptr_to_b.* == 2);
}

const expectEqual = @import("std").testing.expectEqual;
// aligned struct fields
test "aligned struct fields" {
    const SS = struct {
        a: u32 align(2),
        b: u32 align(64),
    };
    var foos = SS{ .a = 1, .b = 2 };

    try expectEqual(64, @alignOf(SS));
    try expectEqual(*align(2) u32, @TypeOf(&foos.a));
    try expectEqual(*align(64) u32, @TypeOf(&foos.b));
}
