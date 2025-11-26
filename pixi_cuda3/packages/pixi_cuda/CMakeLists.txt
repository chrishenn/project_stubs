cmake_minimum_required(VERSION 4.0)
project(csrc)

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

file(GLOB CPP_SRC csrc/*.cpp)
file(GLOB CU_SRC csrc/*.cu)
file(GLOB H_SRC csrc/*.h)
nanobind_add_module(${PROJECT_NAME} ${CPP_SRC} ${CU_SRC} ${H_SRC})
target_link_libraries(${PROJECT_NAME} PRIVATE ${TORCH_LIBRARIES})

# installing "csrc" artifact into "pixi_cuda" build tree such that it gets packaged up - no worky
# install(
    # TARGETS ${PROJECT_NAME}
    # EXPORT ${PROJECT_NAME}Targets
    # LIBRARY DESTINATION ${PYTHON_SITE_PACKAGES}
    # ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    # RUNTIME DESTINATION ${BINDIR}
# )
install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    LIBRARY DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/src/pixi_cuda
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${BINDIR}
)
