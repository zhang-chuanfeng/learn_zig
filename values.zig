const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const hello_world_in_c =
    \\#include <stdio.h>
    \\int main(int argc, char **argv) {
    \\    printf("hello world\n");
    \\    return 0;
    \\}
;

pub fn main() void {
    // integers
    const one_plus_one: i32 = 1 + 1;
    print("1+1={}\n", .{one_plus_one});

    // float
    const seven_div_three: f32 = 7.0 / 3.0;
    print("7.0/3.0={}\n", .{seven_div_three});

    // boolean
    print("{}\n{}\n{}\n", .{ true and false, true or false, !true });

    //optional
    var optional_value: ?[]const u8 = null;
    assert(optional_value == null);
    print("\noptional 1\ntype:{}\nvalue:{?s}\n", .{ @TypeOf(optional_value), optional_value });
    optional_value = "hi";
    assert(optional_value != null);
    print("\noptional 2\ntype:{}\nvalue:{?s}\n", .{ @TypeOf(optional_value), optional_value });

    // error union
    var number_or_error: anyerror!i32 = error.ArgNotFound;
    print("\nerroe union 1\ntype:{}\nvalue:{!}\n", .{ @TypeOf(number_or_error), number_or_error });
    number_or_error = 1234;
    print("\nerroe union 2\ntype:{}\nvalue:{!}\n", .{ @TypeOf(number_or_error), number_or_error });

    print("\n{s}\n", .{hello_world_in_c});
}
