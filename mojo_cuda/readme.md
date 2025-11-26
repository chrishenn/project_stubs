# mojo_cuda

their cuda demo

```bash
pixi run vector_addition

# or
pixi shell
mojo run vector_addition.mojo

# or
mojo build vector_addition.mojo
./vector_addition

# dynamic links
> readelf -d vector_addition
Dynamic section at offset 0x10c90 contains 30 entries:
Tag        Type                         Name/Value
0x0000000000000001 (NEEDED)             Shared library: [libKGENCompilerRTShared.so]
0x0000000000000001 (NEEDED)             Shared library: [libAsyncRTMojoBindings.so]
0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
0x000000000000001d (RUNPATH)            Library runpath: [/home/chris/Projects/project_stubs/mojo_cuda/.pixi/envs/default/lib]

> readelf -h
ELF Header:
  Type:                              DYN (Position-Independent Executable file)

> ldd /home/chris/Projects/project_stubs/mojo_cuda/vector_addition
    linux-vdso.so.1 (0x00007eba436e4000)
    libKGENCompilerRTShared.so => /home/chris/Projects/project_stubs/mojo_cuda/.pixi/envs/default/lib/libKGENCompilerRTShared.so (0x00007eba43200000)
    libAsyncRTMojoBindings.so => /home/chris/Projects/project_stubs/mojo_cuda/.pixi/envs/default/lib/libAsyncRTMojoBindings.so (0x00007eba43666000)
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007eba42e00000)
    libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007eba430e0000)
    libstdc++.so.6 => /home/chris/Projects/project_stubs/mojo_cuda/.pixi/envs/default/lib/libstdc++.so.6 (0x00007eba42c13000)
    libMSupportGlobals.so => /home/chris/Projects/project_stubs/mojo_cuda/.pixi/envs/default/lib/libMSupportGlobals.so (0x00007eba43656000)
    libAsyncRTRuntimeGlobals.so => /home/chris/Projects/project_stubs/mojo_cuda/.pixi/envs/default/lib/libAsyncRTRuntimeGlobals.so (0x00007eba42000000)
    libNVPTX.so => /home/chris/Projects/project_stubs/mojo_cuda/.pixi/envs/default/lib/libNVPTX.so (0x00007eba3f200000)
    libgcc_s.so.1 => /home/chris/Projects/project_stubs/mojo_cuda/.pixi/envs/default/lib/libgcc_s.so.1 (0x00007eba430bf000)
    /lib64/ld-linux-x86-64.so.2 (0x00007eba436e6000)
    libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007eba430ba000)

> pixi clean
> ./vector_addition
    ./vector_addition: error while loading shared libraries: libKGENCompilerRTShared.so: cannot open shared object
     file: No such file or directory

# so it's "Position-Independent" because there's a hardcoded absolute path to the .so's that it links at runtime.
# but it is not "statically built" because there are shared libs linked at runtime.

# I assume this is not implemented yet?
> mojo build --emit py-ext vector_addition.mojo
mojo: error: Unrecognized value for `--emit`. Missing case for: py-ext
```
