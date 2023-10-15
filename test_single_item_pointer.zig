const expect = @import("std").testing.expect;

test "address of syntax" {
    // Get the address of a variable
    const x: i32 = 1234;
    const x_ptr = &x;
    // Dereference a pointer
    try expect(x_ptr.* == 1234);

    // When you get the address of a const variable, you get a const
    // single-item pointer
    try expect(@TypeOf(x_ptr) == *const i32);

    // if you want to mutate the value, you'd need an adress of a mutable variable
    var y: i32 = 5678;
    const y_ptr = &y;
    try expect(@TypeOf(y_ptr) == *i32);
    y_ptr.* += 1;
    try expect(y_ptr.* == 5679);
}

test "pointer array access" {
    var array = [_]u8{ 1, 2, 3, 4, 5, 7, 8 };
    const ptr = &array[2];
    try expect(@TypeOf(ptr) == *u8);
    ptr.* += 1;
    try expect(array[2] == 4);
}
