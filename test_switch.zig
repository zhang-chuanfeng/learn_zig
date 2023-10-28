const std = @import("std");
const builtin = @import("builtin");
const expect = std.testing.expect;

test "switch simple" {
    const a: u64 = 10;
    const zz: u64 = 103;

    const b = switch (a) {
        1, 2, 3 => 0,
        5...100 => 1,
        101 => blk: {
            const c: u64 = 5;
            break :blk c * 2 + 1;
        },
        zz => zz,
        blk: {
            const d: u32 = 5;
            const e: u32 = 100;
            break :blk d + e;
        } => 107,
        else => 9,
    };

    try expect(b == 1);
}

const os_msg = switch (builtin.target.os.tag) {
    .linux => "we found a linux user",
    else => "not a linux user",
};

test "switch inside function" {
    switch (builtin.target.os.tag) {
        .fuchsia => {
            @compileError("fchsia not support");
        },
        else => {},
    }
}

test "switch on tagged union" {
    const Point = struct {
        x: u8,
        y: u8,
    };
    const Item = union(enum) { a: u32, c: Point, d, e: u32 };
    var a = Item{ .c = Point{ .x = 1, .y = 2 } };
    const b = switch (a) {
        Item.a, Item.e => |item| item,
        Item.c => |*item| blk: {
            item.*.x += 1;
            break :blk 6;
        },
        Item.d => 8,
    };
    try expect(b == 6);
    try expect(a.c.x == 2);
}

const Color = enum {
    auto,
    off,
    on,
};

test "exhaustive switching" {
    const color = Color.off;
    const result = switch (color) {
        .auto => false,
        .on => false,
        .off => true,
    };
    try expect(result);
}

fn isFieldOptional(comptime T: type, field_index: usize) !bool {
    const fields = @typeInfo(T).Struct.fields;
    return switch (field_index) {
        inline 0...fields.len - 1 => |idx| @typeInfo(fields[idx].type) == .Optional,
        else => return error.IndexOutOfBounds,
    };
}
const Struct1 = struct { a: u32, b: ?u32 };

const expectError = std.testing.expectError;
test "using @typeInfo with runtime values" {
    var index: usize = 0;
    try expect(!try isFieldOptional(Struct1, index));
    index += 1;
    try expect(try isFieldOptional(Struct1, index));
    index += 1;
    try expectError(error.IndexOutOfBounds, isFieldOptional(Struct1, index));
}

// test inline for inline else

const SliceTypeA = extern struct {
    len: usize,
    ptr: [*]u32,
};
const SliceTypeB = extern struct {
    ptr: [*]SliceTypeA,
    len: usize,
};
const AnySlice = union(enum) {
    a: SliceTypeA,
    b: SliceTypeB,
    c: []const u8,
    d: []AnySlice,
};

fn withFor(any: AnySlice) usize {
    const Tag = @typeInfo(AnySlice).Union.tag_type.?;
    // with `inline for` the function gets generated as a serial of `if`
    // statements relying on the optimizer to convert it to a switch
    inline for (@typeInfo(Tag).Enum.fields) |field| {
        if (field.value == @intFromEnum(any)) {
            return @field(any, field.name).len;
        }
    }
    // when using `inline for` the compiler doesn't know that every
    // possible case has been handled requiring an explicit `unreachable`
    unreachable;
}

fn withSwitch(any: AnySlice) usize {
    return switch (any) {
        inline else => |slice| slice.len,
    };
}

test "inline for and inline else similarity" {
    var any = AnySlice{ .c = "hello" };
    try expect(withFor(any) == 5);
    try expect(withSwitch(any) == 5);
}

// inline switch union enum
// inline switch union tag
const U = union(enum) {
    a: u32,
    b: f32,
};

fn getNum(u: U) u32 {
    switch (u) {
        inline else => |num, tag| {
            if (tag == .b) {
                return @intFromFloat(num);
            }
            return num;
        },
    }
}

test "test" {
    var u = U{ .b = 42 };
    try expect(getNum(u) == 42);
}
