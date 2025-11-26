https://github.com/akhildevelops/cudaz

cudaz builds cuda kernels into c compilation units by passing them (as strings!) to nvrtc.
cudaz can then invoke the compiled ptx directly from zig.
Cuda compilation happens at runtime.
