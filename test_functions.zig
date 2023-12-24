const std = @import("std");
const builtin = @import("builtin");
const native_arch = builtin.cpu.arch;
const expect = std.testing.expect;

// Function are declared like this
fn add(a: i8, b: i8) i8 {
    if (a == 0) {
        return b;
    }
    return a + b;
}

export fn sun(a: i8, b: i8) i8 {
    return a - b;
}

const WINAPI: std.builtin.CallingConvention = if (native_arch == .x86) .Stdcall else .C;
extern "kernel32" fn ExitProcess(exit_code: u32) callconv(WINAPI) noreturn;
extern "c" fn atan2(a: f64, b: f64) f64;

// The @setCold builtin tells the optimizer that a function is rarely called.
fn abort() noreturn {
    @setCold(true);
    while (true) {}
}

fn _start() callconv(.Naked) noreturn {
    abort();
}

// The inline calling convention forces to be inlined at all call sites.
// If the function cannot be inlined, it is a compile-time error.
inline fn shiftLeftOne(a: u32) u32 {
    return a << 1;
}

pub fn sub2(a: i8, b: i8) i8 {
    return a - b;
}

// Function pointers are prefixed with `*const`
const call2_op = *const fn (a: i8, b: i8) i8;
fn do_op(fn_call: call2_op, op1: i8, op2: i8) i8 {
    return fn_call(op1, op2);
}

test "function" {
    try expect(do_op(add, 5, 6) == 11);
    try expect(do_op(sub2, 5, 6) == -1);
}

// Struct,unions,and arrays can sometimes be more efficiently passed
// as a reference, since a copy could be arbitrarily expensive depending on
// the size. When these types are passed as parameters, Zig may choose
// to copy and pass by value, or pass by reference, whichever way Zig decides
// will be faster.

// For extern functions,Zig follows the C ABI for passing structs and unions
// by values.

// anytype
fn addFortyTwo(x: anytype) @TypeOf(x) {
    return x + 42;
}

test "fn test inference" {
    try expect(addFortyTwo(1) == 43);
    try expect(@TypeOf(addFortyTwo(1)) == comptime_int);
    const y: i64 = 2;
    try expect(addFortyTwo(y) == 44);
    try expect(@TypeOf(addFortyTwo(y)) == i64);
}

// fn reflection
const math = std.math;
test "fn reflection" {
    try expect(@typeInfo(@TypeOf(expect)).Fn.params[0].type.? == bool);
    try expect(@typeInfo(@TypeOf(math.Log2Int)).Fn.is_generic);
}
