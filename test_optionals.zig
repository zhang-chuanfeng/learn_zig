const expect = @import("std").testing.expect;

test "optional type" {
    var foo: ?i32 = null;

    foo = 1234;

    try comptime expect(@typeInfo(@TypeOf(foo)).Optional.child == i32);
}

test "optional pointers" {
    // Pointers cannot be null.If you want a null pointer, use the optional
    // prefix `?` to make the pointer type optional.
    var ptr: ?*i32 = null;
    var x: i32 = 1;
    ptr = &x;

    try expect(ptr.?.* == 1);

    try expect(@sizeOf(?*i32) == @sizeOf(*i32));
}
