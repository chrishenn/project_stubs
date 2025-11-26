cmake_minimum_required(VERSION 4.0)
project($ENV{PKG_NAME})

find_package(Python 3.13 EXACT REQUIRED COMPONENTS Development Interpreter)
list(APPEND CMAKE_PREFIX_PATH ${Python_SITELIB} ${Python_STDLIB})
find_package(nanobind CONFIG REQUIRED)

nanobind_add_module(${PROJECT_NAME} STABLE_ABI src/pixi/math.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE Python::Python)

install(
    TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION ${Python_SITELIB}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${BINDIR}
)
