const expect = @import("std").testing.expect;
const mem = @import("std").mem;

const Type = enum {
    ok,
    not_ok,
};

test "Type enum" {
    try expect(@typeInfo(Type).Enum.tag_type == u1);
    const c = Type.ok;
    try expect(@TypeOf(c) == Type);
}

const Value = enum(u2) {
    zero,
    one,
    two,
};

test "enum ordinal value" {
    try expect(@intFromEnum(Value.zero) == 0);
    try expect(@intFromEnum(Value.one) == 1);
    try expect(@intFromEnum(Value.two) == 2);
}

const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
};

test "enum ordinal value 2" {
    try expect(@intFromEnum(Value2.hundred) == 100);
    try expect(@intFromEnum(Value2.thousand) == 1000);
    try expect(@intFromEnum(Value2.million) == 1000000);
}

const Suit = enum {
    clubs, //梅花
    spades, //黑桃
    diamonds, //钻石
    hearts, //红心

    // 不写pub也可以
    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};

test "enum method" {
    const p = Suit.spades;
    try expect(!p.isClubs());
    try expect(!Suit.isClubs(p));
}

const Foo = enum {
    string,
    number,
    none,
};

test "enum switch" {
    const p = Foo.number;
    const what_is_it = switch (p) {
        Foo.string => "this is a string",
        Foo.number => "this is a number",
        Foo.none => "this is a none",
    };
    try expect(mem.eql(u8, what_is_it, "this is a number"));
}

const Small = enum {
    one,
    two,
    three,
    four,
};

test "tag @typeInfo @tagName" {
    try expect(@typeInfo(Small).Enum.tag_type == u2);
    try expect(@typeInfo(Small).Enum.fields.len == 4);
    try expect(mem.eql(u8, @typeInfo(Small).Enum.fields[1].name, "two"));
    try expect(mem.eql(u8, @tagName(Small.three), "three"));
}

// C-ABI-compatible enum
const Foo2 = enum(c_int) { a, b, c };
export fn entry(foo: Foo2) void {
    _ = foo;
}

const Color = enum {
    auto,
    off,
    on,
};

test "enum literals" {
    const color: Color = .auto;
    const color2 = Color.auto;
    try expect(color == color2);
}

test "switch using enum literals" {
    const color = Color.on;
    const result = switch (color) {
        .auto => false,
        .on => true,
        .off => false,
    };
    try expect(result);
}

// Non-exhaustive enum
const Number = enum(u8) {
    one,
    two,
    three,
    _,
};

test "switch on non-exhaustive enum" {
    const number = Number.one;
    const result = switch (number) {
        .one => true,
        .two, .three => false,
        _ => false,
    };
    try expect(result);
    const is_one = switch (number) {
        .one => true,
        else => false,
    };
    try expect(is_one);
}
