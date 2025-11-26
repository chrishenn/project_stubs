// pydust hello world
//
// const py = @import("pydust");
//
// pub fn hello() !py.PyString {
//     return try py.PyString.create("Hello world from zig!");
// }
//
// comptime {
//     py.rootmodule(@This());
// }


// cudaz hello world
const std = @import("std");

pub fn build(b: *std.Build) !void {
    // exe points to main.zig that uses cudaz
    const exe = b.addExecutable(.{ .name = "main", .root_module = b.createModule(.{ .root_source_file = b.path("main.zig"), .target = b.standardTargetOptions(.{}) }) });

    // Point to cudaz dependency
    // Hardcoded CUDA_PATH is not work-around-able
    const cudaz_dep = b.dependency(
        "cudaz",
        .{ .CUDA_PATH = @as([]const u8, "/home/chris/Projects/pycu_zig/.spack-env/view") }
    );

    // Fetch and add the module from cudaz dependency
    const cudaz_module = cudaz_dep.module("cudaz");
    exe.root_module.addImport("cudaz", cudaz_module);

    // Dynamically link to libc, cuda, nvrtc
    exe.linkLibC();
    exe.linkSystemLibrary("cuda");
    exe.linkSystemLibrary("nvrtc");

    // install the "main" program bin to zig-out
    b.installArtifact(exe);

    // Run binary
    const run = b.step("run", "Run the binary");
    const run_step = b.addRunArtifact(exe);
    run.dependOn(&run_step.step);
}
