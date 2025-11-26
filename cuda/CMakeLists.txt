cmake_minimum_required(VERSION 4.0)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CUDA_STANDARD 26)

project(cuda LANGUAGES C CUDA CXX)

find_package(CUDAToolkit REQUIRED)

add_executable(cuda main.cu)
set_target_properties(cuda PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
)
