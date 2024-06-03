const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

// ?T
test "split iterator" {
    const text = "robust, optimal, reusable, maintainable, ";
    var iter = std.mem.split(u8, text, ", ");
    try expect(eql(u8, iter.next().?, "robust"));
    try expect(eql(u8, iter.next().?, "optimal"));
    try expect(eql(u8, iter.next().?, "reusable"));
    try expect(eql(u8, iter.next().?, "maintainable"));
    try expect(eql(u8, iter.next().?, ""));
    try expect(iter.next() == null);
}

// !?T
test "iterator looping" {
    const dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    var iter = dir.iterate();
    var file_count: usize = 0;
    while (try iter.next()) |entry| {
        if (entry.kind == .file) file_count += 1;

        try expect(file_count > 0);
    }
}
