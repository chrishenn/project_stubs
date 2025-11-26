cmake_minimum_required(VERSION 4.0)

set(TORCH_CUDA_ARCH_LIST "8.6")
# set(CAFFE2_USE_CUDNN on)
# set(CAFFE2_USE_CUSPARSELT on)
# set(CAFFE2_USE_CUFILE on)
# set(USE_CUDSS on)

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
project(csrc LANGUAGES CUDA CXX)

find_package(Python COMPONENTS Interpreter Development.Module REQUIRED)
execute_process(
  COMMAND "${Python_EXECUTABLE}" -m nanobind --cmake_dir
  OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE nanobind_ROOT
)
execute_process(
    COMMAND ${Python_EXECUTABLE} -c "import sysconfig; print(sysconfig.get_path('purelib'))"
    OUTPUT_VARIABLE PYTHON_SITE_PACKAGES
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
find_package(Torch REQUIRED)
find_package(nanobind CONFIG REQUIRED)

file(GLOB CPP_SRC ./*.cpp)
file(GLOB CU_SRC ./*.cu)
file(GLOB H_SRC ./*.h)
nanobind_add_module(${PROJECT_NAME} ${CPP_SRC} ${CU_SRC} ${H_SRC})
target_link_libraries(${PROJECT_NAME} PRIVATE ${TORCH_LIBRARIES})


# install the .so directly into the pixi_cuda src files, and find by name
# install(
    # TARGETS ${PROJECT_NAME}
    # EXPORT ${PROJECT_NAME}Targets
    # LIBRARY DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../../src/pixi_cuda
    # ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    # RUNTIME DESTINATION ${BINDIR}
# )

# install the .so as if it were a python package named "csrc", and use the package name to find the .so file
install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    LIBRARY DESTINATION ${PYTHON_SITE_PACKAGES}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${BINDIR}
)
