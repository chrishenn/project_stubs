cmake_minimum_required(VERSION 3.30 FATAL_ERROR)
set(EXT_NAME "_C")

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
project(${EXT_NAME} LANGUAGES CUDA CXX)

find_package(Python REQUIRED COMPONENTS Development Interpreter)
list(APPEND CMAKE_PREFIX_PATH ${Python_SITELIB} ${Python_STDLIB})
set(CAFFE2_USE_CUDNN on)
set(CAFFE2_USE_CUSPARSELT on)
set(CAFFE2_USE_CUFILE on)
set(USE_CUDSS on)
find_package(Torch REQUIRED)
find_package(nanobind CONFIG REQUIRED)

file(GLOB CPP_SRC csrc/*.cpp)
file(GLOB CU_SRC csrc/*.cu)
file(GLOB H_SRC csrc/*.h)
nanobind_add_module(${EXT_NAME} STABLE_ABI LTO ${CPP_SRC} ${CU_SRC} ${H_SRC})
set_target_properties(${EXT_NAME} PROPERTIES
    CUDA_STANDARD 20
    CUDA_ARCHITECTURES native
)
target_link_libraries(${EXT_NAME} PRIVATE ${TORCH_LIBRARIES})
