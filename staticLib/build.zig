const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libfizzbuzz = b.addStaticLibrary(.{
        .name = "fizzbuzz",
        .root_source_file = .{ .path = "fizzbuzz.zig" },
        .target = target,
        .optimize = optimize,
    });

    const libfizzbuzzdy = b.addSharedLibrary(.{
        .name = "fizzbuzz",
        .root_source_file = .{ .path = "fizzbuzz.zig" },
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 1, .minor = 2, .patch = 3 },
    });

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_source_file = .{ .path = "demo.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(libfizzbuzz);

    b.installArtifact(libfizzbuzz);
    b.installArtifact(libfizzbuzzdy);
    if (b.option(bool, "enable-demo", "install the demo too") orelse false) {
        b.installArtifact(exe);
    }
}
