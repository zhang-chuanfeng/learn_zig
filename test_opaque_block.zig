// opaque {} declares a new type with an known size and alignment.
// opaque is typically used for type safety when interacting with C code
// that does not expose struct details

const Drep = opaque {};
const Wat = opaque {};

// extern fn bar(d: *Drep) void;
// fn foo(w: *Wat) callconv(.C) void {
//     bar(w);
// }

// test "call foo" {
//     foo(undefined);
// }

// block
const expect = @import("std").testing.expect;
test "labeled break from labeled block expression" {
    var y: i32 = 123;

    const x = blk: {
        y += 1;
        break :blk y;
    };
    try expect(x == 124);
    try expect(y == 124);
}

test "empty block" {
    const a = {};
    const b = void{};
    try expect(@TypeOf(a) == void);
    try expect(@TypeOf(b) == void);
    try expect(a == b);
}
