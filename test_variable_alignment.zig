const std = @import("std");
const builtin = @import("builtin");
const expect = std.testing.expect;

test "variable alignment" {
    var x: i32 = 1234;
    const align_of_i32 = @alignOf(@TypeOf(x));
    try expect(align_of_i32 == 4);
    try expect(@TypeOf(&x) == *i32);
    try expect(*i32 == *align(align_of_i32) i32);
    if (builtin.target.cpu.arch == .x86_64) {
        try expect(@typeInfo(*i32).Pointer.alignment == 4);
    }
}

var foo: u8 align(4) = 100;

test "global variable alignment" {
    try expect(@typeInfo(@TypeOf(&foo)).Pointer.alignment == 4);
    try expect(@TypeOf(&foo) == *align(4) u8);
    const as_slice2: []u8 = @as(*[1]u8, &foo);
    try expect(as_slice2[0] == 100);
    const as_pointer_to_array: *align(4) [1]u8 = &foo;
    const as_slice: []align(4) u8 = as_pointer_to_array;
    const as_unaligned_slice: []u8 = as_slice;
    try expect(as_unaligned_slice[0] == 100);
}

fn derp() align(@sizeOf(usize) * 2) i32 {
    return 1234;
}
fn noop1() align(1) void {}
fn noop2() align(4) void {}

test "function alignment" {
    try expect(derp() == 1234);
    try expect(@TypeOf(noop1) == fn () align(1) void);
    try expect(@TypeOf(noop2) == fn () align(4) void);
    noop1();
    noop2();
}

test "pointer alignment safety" {
    var array align(4) = [_]u32{ 0x11111111, 0x11111111 };
    const bytes = std.mem.sliceAsBytes(array[0..]);
    try expect(foof(bytes) == 0x11111111);
}

fn foof(bytes: []u8) u32 {
    const slice4 = bytes[1..5];
    const int_slice = std.mem.bytesAsSlice(u32, @as([]align(1) u8, @alignCast(slice4)));
    return int_slice[0];
}

test "allowzero" {
    var zero: usize = 0;
    var ptr: *allowzero i32 = @ptrFromInt(zero);
    try expect(@intFromPtr(ptr) == 0);
}

pub extern "c" fn printf(format: [*:0]const u8, ...) c_int;

pub fn main() anyerror!void {
    _ = printf("hello, world!\n");

    const msg = "hello, world\n";
    const non_null_terminated_msg: [msg.len:0]u8 = msg.*;
    _ = printf(&non_null_terminated_msg);
}
