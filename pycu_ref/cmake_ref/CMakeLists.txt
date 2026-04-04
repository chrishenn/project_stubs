cmake_minimum_required(VERSION 3.30 FATAL_ERROR)

set(PROJECT "_C")
project(${PROJECT} LANGUAGES CUDA CXX)
find_package(Torch REQUIRED)

file(GLOB CPP_SRC ext/*.cpp )
file(GLOB CU_SRC ext/*.cu)
file(GLOB H_SRC ext/*.h )

add_library(${PROJECT} SHARED ${CPP_SRC} ${CU_SRC} ${H_SRC})
target_include_directories(${PROJECT} PUBLIC ${TORCH_INCLUDE_DIR})
target_link_libraries(${PROJECT} ${TORCH_LIBRARIES})
