https://github.com/Marco-Christiani/zigrad/blob/main/src/cuda/CMakeLists.txt

the build.zig will invoke a python script, which will invoke cmake using a subprocess.
The cmake call uses a minimal cmakelists to build a single .so from a single .cu file that imports everything.
In parallel, a zig file imports manually copy-pasted function definitions from a header that independently tracks
all the included cu functions.
