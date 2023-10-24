const std = @import("std");
const expect = std.testing.expect;

test "basic slices" {
    var array = [_]i32{ 1, 2, 3, 4 };
    try expect(@TypeOf(array) == [array.len]i32);
    try expect(@TypeOf(&array) == *[array.len]i32);
    try expect(@TypeOf(&array[0]) == *i32);

    var known_at_runtime_zero: usize = 0;
    const slice = array[known_at_runtime_zero..array.len];
    try expect(@TypeOf(slice) == []i32);
    try expect(@TypeOf(slice.ptr) == [*]i32);
    try expect(slice.len == array.len);
    try expect(&slice[0] == &array[0]);

    const array_ptr = array[0..array.len];
    try expect(@TypeOf(array_ptr) == *[array.len]i32);
    try expect(@TypeOf(array_ptr) == @TypeOf(&array));
    try expect(array_ptr == &array);
    try expect(array_ptr.len == array.len);

    var runtime_start: usize = 1;
    const length = 2;
    const array_ptr_len = array[runtime_start..][0..length];
    try expect(@TypeOf(array_ptr_len) == *[length]i32);

    try expect(@TypeOf(slice.ptr) == [*]i32);
    try expect(@intFromPtr(slice.ptr) == @intFromPtr(&array));
}
