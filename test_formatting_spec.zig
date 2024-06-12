const std = @import("std");
const eql = std.mem.eql;

test "hex" {
    var b: [10]u8 = undefined;

    const s = try std.fmt.bufPrint(&b, "0x{X:0>8}", .{429});
    std.debug.print("{s}\n", .{s});
}

test "position" {
    var b: [3]u8 = undefined;
    try std.testing.expect(eql(u8, try std.fmt.bufPrint(&b, "{0s}{0s}{1s}", .{ "a", "b" }), "aab"));
}
