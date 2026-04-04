cmake_minimum_required(VERSION 3.30 FATAL_ERROR)

set(PNAME ${SKBUILD_PROJECT_NAME})
set(PVER ${SKBUILD_PROJECT_VERSION})
project(
    ${PNAME}
    LANGUAGES CUDA CXX
    VERSION ${PVER}
)

find_package(CUDAToolkit REQUIRED)
find_package(Torch REQUIRED)
include_directories(${TORCH_INCLUDE_DIRS})

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${TORCH_CXX_FLAGS}")

file(GLOB CPP_SRC *.cpp )
file(GLOB CU_SRC *.cu)
file(GLOB H_SRC *.h )

add_library(${PNAME} SHARED ${CPP_SRC} ${CU_SRC} ${H_SRC} )
target_link_libraries(${PNAME} ${TORCH_LIBRARIES})
install(TARGETS ${PNAME} LIBRARY DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
