set_xmakever("2.9.7")
add_rules("mode.release", "mode.debug")

set_languages("c++17")
add_requires("python", {system = true})

-- I don't know how to resolve the site-packages path for our python install, using lua. That would be nice
-- add_requires("cmake::Torch", {alias = "libtorch", configs = {envs = {CMAKE_PREFIX_PATH = ./path-to-site-packages/}}})

-- Use prebuilt libtorch: download the libtorch zip and extract it to ext/
-- add_requires("cmake::Torch", {alias = "libtorch", configs = {envs = {Torch_DIR = path.absolute("ext/libtorch")}}})

-- Build libtorch from src using the xmake.lua in repo/packages/l/libtorch/xmake.lua
add_repositories("localrepo repo")
add_requires("libtorch", {configs = {cmshared=true, cuda=true}})

target("_C")
    add_rules("python.library", {soabi = true})
    add_files("csrc/*.cpp")
    add_files("csrc/*.cu")
    add_files("csrc/*.h")

    add_packages("python")
    add_packages("libtorch")

    -- debugging only: build for native gpu
    add_cugencodes("native")
