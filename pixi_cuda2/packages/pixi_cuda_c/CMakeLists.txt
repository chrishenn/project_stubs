cmake_minimum_required(VERSION 4.0)

# PKG_NAME provided by pixi-build-cmake
project($ENV{PKG_NAME} LANGUAGES CUDA CXX)

# only cudnn, cudss working
set(CAFFE2_USE_CUDNN on)
set(CAFFE2_USE_CUSPARSELT on)
set(CAFFE2_USE_CUFILE on)
set(USE_CUDSS on)

find_package(Python REQUIRED COMPONENTS Development Interpreter)
list(APPEND CMAKE_PREFIX_PATH ${Python_SITELIB} ${Python_STDLIB})
find_package(CUDAToolkit REQUIRED)
find_package(Torch REQUIRED)
find_package(nanobind CONFIG REQUIRED)

file(GLOB CPP_SRC ./*.cpp)
file(GLOB CU_SRC ./*.cu)
file(GLOB H_SRC ./*.h)
nanobind_add_module(${PROJECT_NAME} ${CPP_SRC} ${CU_SRC} ${H_SRC})
target_include_directories(${PROJECT_NAME} PRIVATE ${TORCH_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE ${TORCH_LIBRARIES})

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    LIBRARY DESTINATION ${Python_SITELIB}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${BINDIR}
)
