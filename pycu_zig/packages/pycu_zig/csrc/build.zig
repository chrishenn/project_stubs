// pydust hello world

const py = @import("pydust");

pub fn hello() !py.PyString {
    return try py.PyString.create("Hello world from zig!");
}

comptime {
    py.rootmodule(@This());
}
