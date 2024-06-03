const std = @import("std");

test "GPA" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    _ = std.heap.ArenaAllocator.init(allocator);

    const bytes = try allocator.alloc(u8, 100);
    defer allocator.free(bytes);
}
