const std = @import("std");
const print = std.debug.print;
const mem = std.mem;

pub fn main() void {
    const bytes = "hello";
    print("{}\n", .{@TypeOf(bytes)});
    print("{d}\n", .{bytes.len});
    print("{c}\n", .{bytes[1]});
    print("{d}\n", .{bytes[5]});
    print("{}\n", .{'e' == '\x65'});
    print("{}\n", .{'\u{1f4a9}'});
    print("{d}\n", .{'💯'});
    print("{u}\n", .{'⚡'});
    print("{}\n", .{mem.eql(u8, "hello", "h\x65llo")});
    print("{}\n", .{mem.eql(u8, "💯", "\xf0\x9f\x92\xaf")});
    const invalid_utf8 = "\xff\xfe";
    print("0x{x}\n", .{invalid_utf8[1]});
    print("0x{x}\n", .{"💯"[1]});
    print("{u}\n", .{'😊'});
    print("{x}\n", .{'😊'});
    print("{d}\n", .{'😊'});
    print("{s}\n", .{"\u{1f60a}"});
    print("{u}\n", .{'\u{1f60a}'});
    print("0x{x}{x}{x}{x}\n", .{ "\u{1f60a}"[3], "\u{1f60a}"[2], "\u{1f60a}"[1], "\u{1f60a}"[0] });
    print("{}\n", .{mem.eql(u8, "😊", "\xf0\x9f\x98\x8a")});
}
