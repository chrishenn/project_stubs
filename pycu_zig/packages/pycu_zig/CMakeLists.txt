cmake_minimum_required(VERSION 3.30 FATAL_ERROR)
set(EXT_NAME "_C")

## For local debug.
## Cuda cmake flags and target properties set in here are ignored by Torch's custom cmake files.
set(TORCH_CUDA_ARCH_LIST "8.6")
####

set(CMAKE_C_COMPILER gcc)
set(CMAKE_CXX_COMPILER g++)
set(cuda_flags
    --std=c++17 -Xfatbin -compress-all -Xcudafe --display_error_number
    -DCUDA_PTX_FP8_F2FP_ENABLED -Xcompiler -O3 --use_fast_math -lineinfo --ptxas-options -v)
add_compile_options("$<$<COMPILE_LANGUAGE:CUDA>:${cuda_flags}>")

project(${EXT_NAME} LANGUAGES CUDA CXX)

# uv-installed pytorch and nanobind are findable from Python_SITELIB (on the cmake prefix path)
# when the pytorch.cmake runs to find all pytorch parts, it will be able to find libstdc++ thanks to Python_STDLIB here
find_package(Python COMPONENTS Interpreter Development.Module REQUIRED)
list(APPEND CMAKE_PREFIX_PATH ${Python_SITELIB} ${Python_STDLIB})

find_package(CUDAToolkit REQUIRED)
find_package(Torch REQUIRED)

file(GLOB CPP_SRC csrc/*.cpp)
file(GLOB CU_SRC csrc/*.cu)
file(GLOB H_SRC csrc/*.h)

# pybind and nanobind are interchangeable here
# set (PYBIND11_PYTHON_VERSION "3.13")
# find_package(pybind11 CONFIG REQUIRED)
# pybind11_add_module(${EXT_NAME} MODULE ${CPP_SRC} ${CU_SRC} ${H_SRC})

# Note that nanobind features likes stable_abi are ignored by pytorch's ext macros
# It also appears that pytorch's extension macros are overriding the environment python install
find_package(nanobind CONFIG REQUIRED)
nanobind_add_module(${EXT_NAME} STABLE_ABI LTO ${CPP_SRC} ${CU_SRC} ${H_SRC})

target_link_libraries(${EXT_NAME} PRIVATE ${TORCH_LIBRARIES} ${CUDA_LIBRARIES})
install(TARGETS ${EXT_NAME} LIBRARY DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/src/pycu_skit/")

