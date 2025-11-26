cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

# Global Settings
SET(CMAKE_POLICY NEW)
include(CMakePrintHelpers)

# Create project
SET(MOD_NAME $ENV{MOD_NAME})
SET(PROJECT_NAME ${MOD_NAME})
cmake_print_variables(MOD_NAME)

SET(CMAKE_C_COMPILER gcc)
SET(CMAKE_CXX_COMPILER g++)
SET(CMAKE_CUDA_COMPILER nvcc)

project(${PROJECT_NAME} LANGUAGES CUDA CXX)

# LIBTORCH
FIND_PACKAGE(Torch REQUIRED)

# Source files
file(GLOB INTERNAL_SOURCE ./*.cpp )
file(GLOB CUDA_SOURCE ./*.cu)
file(GLOB INTERNAL_HEADERS ./*.h )

# Define our library target
add_library(${PROJECT_NAME} SHARED ${INTERNAL_SOURCE} ${INTERNAL_HEADERS} ${CUDA_SOURCE} )
target_link_libraries(${PROJECT_NAME} ${TORCH_LIBRARIES})
