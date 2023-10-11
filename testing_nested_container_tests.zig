const std = @import("std");
const expect = @import("std").testing.expect;

const import_file = @import("testing_introduction.zig");

test {
    std.testing.refAllDecls(@This());

    _ = S;
    _ = U;
    _ = @import("testing_introduction.zig");
}

const S = struct {
    test "S demo test" {
        try expect(true);
    }

    const SE = enum {
        V,

        test "this test Won't run" {
            try expect(false);
        }
    };
};

const U = union {
    s: US,

    const US = struct {
        test "U.US demo test" {
            try expect(false);
        }
    };

    test "U demo test" {
        try expect(true);
    }
};
