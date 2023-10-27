// tagged union
// union with enum tag
// use switch with a union

const std = @import("std");
const expect = std.testing.expect;

const ComplexTypeTag = enum {
    ok,
    not_ok,
};

const ComplexType = union(ComplexTypeTag) {
    ok: u8,
    not_ok: void,
};

test "switch on tagged union" {
    const c = ComplexType{ .ok = 42 };
    try expect(@as(ComplexTypeTag, c) == ComplexTypeTag.ok);

    switch (c) {
        ComplexTypeTag.ok => |value| try expect(value == 42),
        ComplexTypeTag.not_ok => unreachable,
    }
}

test "get tag type" {
    try expect(std.meta.Tag(ComplexType) == ComplexTypeTag);
}

test "modify tagged union in switch" {
    var d = ComplexType{ .ok = 42 };
    switch (d) {
        ComplexTypeTag.ok => |*value| value.* += 1,
        ComplexTypeTag.not_ok => unreachable,
    }
    try expect(d.ok == 43);
}

// union method
const Variant = union(enum) {
    int: i32,
    boolean: bool,
    none,

    fn truthy(self: Variant) bool {
        return switch (self) {
            Variant.int => |x_int| x_int != 0,
            Variant.boolean => |x_bool| x_bool,
            Variant.none => false,
        };
    }
};

test "union method" {
    var v1 = Variant{ .int = 1 };
    var v2 = Variant{ .boolean = false };

    try expect(v1.truthy());
    try expect(!v2.truthy());
}

// @tagName
const Small2 = union(enum) {
    a: i32,
    b: bool,
    c: u8,
};
test "@tagName" {
    try expect(std.mem.eql(u8, @tagName(Small2.a), "a"));
}

// extern union
// memory layout guaranteed to be compatible with the target C ABI.

// packed union
// has well-defined in-memory layout

// anonymous union literals

const Number = union {
    int: i32,
    float: f64,
};

test "anonymous union literal syntax" {
    var i: Number = .{ .int = 42 };
    var f = makeNumber();
    try expect(i.int == 42);
    try expect(f.float == 12.34);
}

fn makeNumber() Number {
    return .{ .float = 12.34 };
}
