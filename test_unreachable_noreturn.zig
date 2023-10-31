// In Dehug and ReleaseSafe mode unreachable emits a call to panic with
// the message reached unreachable code.

// In ReleaseFast and ReleaseSmall mode, the optimizer uses the assumption that unreachable code
// will never be hit to perform optimizations.

test "basic math" {
    const x = 1;
    const y = 2;
    if (x + y != 3) {
        unreachable;
    }
}

// test assertion failure
fn myassert(ok: bool) void {
    if (!ok) unreachable;
}
test "this will fail" {
    myassert(true);
}
const std = @import("std");
const assert = std.debug.assert;

test "type of unreachable" {
    comptime {
        // The type of unreachable is noreturn.

        // However this assertion will still fail to compile because
        // unreachable expression are compile errors.
        // assert(@TypeOf(unreachable) == noreturn);
    }
}

// noreturn
// noreturn is the type of
// break
// contiune
// return
// unreachable
// while (true) {}

fn foo(condition: bool, b: u32) void {
    const a = if (condition) b else return;
    _ = a;
    @panic("do something with a");
}
test "noreturn" {
    foo(false, 1);
}

// noturn use case for exit function
const builtin = @import("builtin");
const native_arch = builtin.cpu.arch;
const expect = std.testing.expect;
const WINAPI: std.builtin.CallingConvention = if (native_arch == .x86) .Stdcall else .C;
extern "kernel32" fn ExitProcess(exit_code: c_uint) callconv(WINAPI) noreturn;

test "foo" {
    const value = bar() catch ExitProcess(1);
    try expect(value == 1234);
}

fn bar() anyerror!u32 {
    return 1234;
}
