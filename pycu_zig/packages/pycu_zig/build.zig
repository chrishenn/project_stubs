const std = @import("std");
const builtin = @import("builtin");
const Step = std.Build.Step;
const LazyPath = std.Build.LazyPath;
const GeneratedFile = std.Build.GeneratedFile;


// pub fn build(b: *std.Build) void {
//     const target = b.standardTargetOptions(.{});
//     const optimize = b.standardOptimizeOption(.{});
//
    // const pydust = addPydust(b, .{});

    // const pymod = pydust.addPythonModule(.{
    //     .name = "_C",
    //     .root_source_file = .{ .cwd_relative = "csrc/build.zig" },
    //     .installdir = "src/pycu_zig",
    //     .limited_api = true,
    //     .target = target,
    //     .optimize = optimize,
    // });

    // _ = pydust.addPythonModule(.{
    //     .name = "_C",
    //     .root_source_file = .{ .cwd_relative = "csrc/build.zig" },
    //     .installdir = "src/pycu_zig",
    //     .limited_api = true,
    //     .target = target,
    //     .optimize = optimize,
    // });


    // add external deps
    // pymod.library_step.addModule();

    // I'll tackle the torch dep later
    // const cxxflags = [_][]const u8{"-std=c++17"};
    // .addCSourceFiles(.{"csrc/example.cpp", "csrc/example.cu"}, &[_][]const u8{ &cxxflags });
    // .addCSourceFile("csrc/example.cu", &[_][]const u8{ &cxxflags });

    // const cudaz_dep = b.dependency(
    //     "cudaz",
        // .{}, // replace with `.{ .CUDA_PATH = @as([]const u8, "<your cuda path>") }` to specify custom CUDA_PATH
        //  .{ .CUDA_PATH = @as([]const u8, "/home/chris/Projects/pycu_zig/.spack-env/view") }
    // );

    // Fetch and add the module from cudaz dependency
    // const cudaz_module = cudaz_dep.module("cudaz");
    // pymod.library_step.addImport("cudaz", cudaz_module);

    // Dynamically link to cuda, nvrtc
    // pymod.linkSystemLibrary("cuda");
    // pymod.linkSystemLibrary("nvrtc");
// }

pub const PydustOptions = struct {
    test_step: ?*Step = null,
};

pub const PythonModuleOptions = struct {
    name: [:0]const u8,
    root_source_file: std.Build.LazyPath,
    installdir: []const u8,
    limited_api: bool = true,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.Mode,
    main_pkg_path: ?std.Build.LazyPath = null,

    pub fn short_name(self: *const PythonModuleOptions) [:0]const u8 {
        if (std.mem.lastIndexOfScalar(u8, self.name, '.')) |short_name_idx| {
            return self.name[short_name_idx + 1 .. :0];
        }
        return self.name;
    }
};

pub const PythonModule = struct {
    // library_step: *Step.Compile,
    // test_step: *Step.Compile,
    library_step: *Step,
    test_step: ?*Step = null,
};

/// Configure a Pydust step in the build. From this, you can define Python modules.
pub fn addPydust(b: *std.Build, options: PydustOptions) *PydustStep {
    return PydustStep.add(b, options);
}

pub const PydustStep = struct {
    owner: *std.Build,
    allocator: std.mem.Allocator,
    options: PydustOptions,

    test_build_step: *Step,
    generate_stubs: *Step,
    check_stubs: bool,

    python_exe: []const u8,
    libpython: []const u8,
    hexversion: []const u8,

    pydust_source_file: []const u8,
    python_include_dir: []const u8,
    python_library_dir: []const u8,

    pub fn add(b: *std.Build, options: PydustOptions) *PydustStep {
        const test_build_step = b.step("pydust-test-build", "Build Pydust test runners");
        const generate_stubs = b.step("generate-stubs", "Generate pyi stubs for the compiled binary");
        const check_stubs = b.option(bool, "check-stubs", "Check that existing stubs are up to date instead of generating new ones") orelse false;

        const python_exe = blk: {
            if (b.option([]const u8, "python-exe", "Python executable to use")) |exe| {
                break :blk exe;
            }
            if (getStdOutput(b.allocator, &.{ "poetry", "env", "info", "--executable" })) |exe| {
                // Strip off the trailing newline
                break :blk exe[0 .. exe.len - 1];
            } else |_| {
                break :blk "python3";
            }
        };

        const libpython = getLibpython(
            b.allocator,
            python_exe,
        ) catch @panic("Cannot find libpython");
        const hexversion = getPythonOutput(
            b.allocator,
            python_exe,
            "import sys; print(f'{sys.hexversion:#010x}', end='')",
        ) catch @panic("Cannot get python hexversion");

        var self = b.allocator.create(PydustStep) catch @panic("OOM");

        self.* = .{
            .owner = b,
            .allocator = b.allocator,
            .options = options,
            .test_build_step = test_build_step,
            .generate_stubs = generate_stubs,
            .check_stubs = check_stubs,
            .python_exe = python_exe,
            .libpython = libpython,
            .hexversion = hexversion,
            .pydust_source_file = "",
            .python_include_dir = "",
            .python_library_dir = "",
        };
        // Eagerly run path discovery to work around ZLS support.
        self.python_include_dir = self.pythonOutput(
            "import sysconfig; print(sysconfig.get_path('include'), end='')",
        ) catch @panic("Failed to setup Python");
        self.python_library_dir = self.pythonOutput(
            "import sysconfig; print(sysconfig.get_config_var('LIBDIR'), end='')",
        ) catch @panic("Failed to setup Python");
        self.pydust_source_file = self.pythonOutput(
            "import pydust; import os; print(os.path.join(os.path.dirname(pydust.__file__), 'src/pydust.zig'), end='')",
        ) catch @panic("Failed to setup Python");

        // Option for emitting test binary based on the given root source. This can be helpful for debugging.
        // const debugRoot = b.option(
        //     []const u8,
        //     "debug-root",
        //     "The root path of a file emitted as a binary for use with the debugger",
        // );
        // if (debugRoot) |root| {
        //     {
        //         const pyconf = b.addOptions();
        //         pyconf.addOption([:0]const u8, "module_name", "debug");
        //         pyconf.addOption(bool, "limited_api", false);
        //         pyconf.addOption([]const u8, "hexversion", hexversion);
        //
        //         const testdebug = b.addTest(.{ .root_source_file = .{ .path = root }, .target = .{}, .optimize = .Debug });
        //         testdebug.addOptions("pyconf", pyconf);
        //         testdebug.addAnonymousModule("pydust", .{
        //             .source_file = .{ .path = self.pydust_source_file },
        //             .dependencies = &.{.{ .name = "pyconf", .module = pyconf.createModule() }},
        //         });
        //         testdebug.addIncludePath(.{ .path = self.python_include_dir });
        //         testdebug.linkLibC();
        //         testdebug.linkSystemLibrary(libpython);
        //         testdebug.addLibraryPath(.{ .path = self.python_library_dir });
        //         // Needed to support miniconda statically linking libpython on macos
        //         testdebug.addRPath(.{ .path = self.python_library_dir });
        //
        //         const debugBin = b.addInstallBinFile(testdebug.getEmittedBin(), "debug.bin");
        //         b.getInstallStep().dependOn(&debugBin.step);
        //     }
        // }

        return self;
    }

    /// Adds a Pydust Python module. The resulting library and test binaries can be further configured with
    /// additional dependencies or modules.
    pub fn addPythonModule(self: *PydustStep, options: PythonModuleOptions) PythonModule {
        const b = self.owner;

        const short_name = options.short_name();

        // const pyconf = b.addOptions();
        // pyconf.addOption([:0]const u8, "module_name", options.name);
        // pyconf.addOption(bool, "limited_api", options.limited_api);
        // pyconf.addOption([]const u8, "hexversion", self.hexversion);

        // Configure and install the Python module shared library
        const lib = b.addSharedLibrary(.{
            .name = short_name,
            .root_source_file = options.root_source_file,
            .target = options.target,
            .optimize = options.optimize,

        });
        // lib.addOptions("pyconf", pyconf);
        // lib.addAnonymousModule("pydust", .{
        //     .source_file = .{ .path = self.pydust_source_file },
        //     .dependencies = &.{.{ .name = "pyconf", .module = pyconf.createModule() }},
        // });

        const pydustmod = b.createModule(.{
            .root_source_file = self.pydust_source_file,
            // .module_name = options.name,
            // .limited_api = options.limited_api,
            // .hexversion = self.hexversion,
        });
        lib.linkLibrary(pydustmod);
        lib.addIncludePath(.{ .path = self.python_include_dir });
        lib.linkLibC();
        lib.linker_allow_shlib_undefined = true;

        // Install the shared library within the source tree
        var outd = std.ArrayList(u8).init(self.allocator);
        defer outd.deinit();
        outd.appendSlice("../") catch @panic("OOM");
        outd.appendSlice(options.installdir) catch @panic("OOM");
        const install = b.addInstallFileWithDir(
            lib.getEmittedBin(),
            .{ .custom = outd.items },
            libraryDestRelPath(self.allocator, options) catch @panic("OOM"),
        );
        b.getInstallStep().dependOn(&install.step);

        // Invoke stub generator on the emitted binary
        const workingDir = std.fs.cwd().realpathAlloc(self.allocator, ".") catch @panic("OOM");
        var genArgs: []const []const u8 = undefined;
        if (self.check_stubs) {
            genArgs = &.{ self.python_exe, "-m", "pydust.generate_stubs", options.name, workingDir, "--check" };
        } else {
            genArgs = &.{ self.python_exe, "-m", "pydust.generate_stubs", options.name, workingDir };
        }
        const stubs = b.addSystemCommand(genArgs);
        stubs.step.dependOn(&install.step);
        self.generate_stubs.dependOn(&stubs.step);

        // Configure a test runner for the module
        // const libtest = b.addTest(.{
        //     .root_source_file = options.root_source_file,
        //     .main_pkg_path = options.main_pkg_path,
        //     .target = options.target,
        //     .optimize = options.optimize,
        // });
        // libtest.addOptions("pyconf", pyconf);
        // libtest.addAnonymousModule("pydust", .{
        //     .source_file = .{ .path = self.pydust_source_file },
        //     .dependencies = &.{.{ .name = "pyconf", .module = pyconf.createModule() }},
        // });
        // libtest.addIncludePath(.{ .path = self.python_include_dir });
        // libtest.linkLibC();
        // libtest.linkSystemLibrary(self.libpython);
        // libtest.addLibraryPath(.{ .path = self.python_library_dir });
        // // Needed to support miniconda statically linking libpython on macos
        // libtest.addRPath(.{ .path = self.python_library_dir });
        //
        // // Install the test binary
        // const install_libtest = b.addInstallBinFile(
        //     libtest.getEmittedBin(),
        //     testDestRelPath(self.allocator, short_name) catch @panic("OOM"),
        // );
        // self.test_build_step.dependOn(&install_libtest.step);

        // Run the tests as part of zig build test.
        // if (self.options.test_step) |test_step| {
        //     const run_libtest = b.addRunArtifact(libtest);
        //     test_step.dependOn(&run_libtest.step);
        // }

        return .{
            .library_step = lib,
            // .test_step = libtest,
        };
    }

    fn libraryDestRelPath(allocator: std.mem.Allocator, options: PythonModuleOptions) ![]const u8 {
        const name = options.name;

        if (!options.limited_api) {
            @panic("Pydust currently only supports limited API");
        }

        const suffix = ".abi3.so";
        const destPath = try allocator.alloc(u8, name.len + suffix.len);

        // Take the module name, replace dots for slashes.
        @memcpy(destPath[0..name.len], name);
        std.mem.replaceScalar(u8, destPath[0..name.len], '.', '/');

        // Append the suffix
        @memcpy(destPath[name.len..], suffix);

        return destPath;
    }

    fn testDestRelPath(allocator: std.mem.Allocator, short_name: []const u8) ![]const u8 {
        const suffix = ".test.bin";
        const destPath = try allocator.alloc(u8, short_name.len + suffix.len);

        @memcpy(destPath[0..short_name.len], short_name);
        @memcpy(destPath[short_name.len..], suffix);

        return destPath;
    }

    fn pythonOutput(self: *PydustStep, code: []const u8) ![]const u8 {
        return getPythonOutput(self.allocator, self.python_exe, code);
    }
};

fn getLibpython(allocator: std.mem.Allocator, python_exe: []const u8) ![]const u8 {
    const ldlibrary = try getPythonOutput(
        allocator,
        python_exe,
        "import sysconfig; print(sysconfig.get_config_var('LDLIBRARY'), end='')",
    );

    var libname = ldlibrary;

    // Strip libpython3.11.a.so => python3.11.a.so
    if (std.mem.eql(u8, ldlibrary[0..3], "lib")) {
        libname = libname[3..];
    }

    // Strip python3.11.a.so => python3.11.a
    const lastIdx = std.mem.lastIndexOfScalar(u8, libname, '.') orelse libname.len;
    libname = libname[0..lastIdx];

    return libname;
}

fn getPythonOutput(allocator: std.mem.Allocator, python_exe: []const u8, code: []const u8) ![]const u8 {
    const result = try runProcess(.{
        .allocator = allocator,
        .argv = &.{ python_exe, "-c", code },
    });
    if (result.term.Exited != 0) {
        std.debug.print("Failed to execute {s}:\n{s}\n", .{ code, result.stderr });
        std.process.exit(1);
    }
    allocator.free(result.stderr);
    return result.stdout;
}

fn getStdOutput(allocator: std.mem.Allocator, argv: []const []const u8) ![]const u8 {
    const result = try runProcess(.{ .allocator = allocator, .argv = argv });
    if (result.term.Exited != 0) {
        std.debug.print("Failed to execute {any}:\n{s}\n", .{ argv, result.stderr });
        std.process.exit(1);
    }
    allocator.free(result.stderr);
    return result.stdout;
}

const runProcess = if (builtin.zig_version.minor >= 12) std.process.Child.run else std.process.Child.exec;

