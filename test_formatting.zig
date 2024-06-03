const std = @import("std");

const test_allocator = std.testing.allocator;

test "format" {
    const string = try std.fmt.allocPrint(test_allocator, "{d}+{d}={d}", .{ 9, 10, 19 });
    defer test_allocator.free(string);

    try std.testing.expect(std.mem.eql(u8, string, "9+10=19"));
}

// std.debug.print 打印到stderr 并受mutex保护
test "print" {
    var list = std.ArrayList(u8).init(test_allocator);
    defer list.deinit();
    try list.writer().print("{}+{}={}", .{ 9, 10, 19 });
    try std.testing.expect(std.mem.eql(u8, list.items, "9+10=19"));
}

test "hello world" {
    const out_file = std.io.getStdOut();
    try out_file.writer().print("Hello, {s}!\n", .{"World"});
}

test "arry print" {
    const string = try std.fmt.allocPrint(test_allocator, "{any}+{any}={any}", .{ @as([]const u8, &[_]u8{ 1, 4 }), @as([]const u8, &[_]u8{ 2, 5 }), @as([]const u8, &[_]u8{ 3, 9 }) });
    defer test_allocator.free(string);
    std.debug.print("{s}\n", .{string});

    try std.testing.expect(std.mem.eql(u8, string, "{ 1, 4 }+{ 2, 5 }={ 3, 9 }"));
}

// 定制format接口
// 实现 value.format(actual_fmt, options, writer);
