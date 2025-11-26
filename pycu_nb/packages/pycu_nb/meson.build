project(
    'pycu_nb',
    ['c', 'cpp', 'cuda'],
    default_options : ['cpp_std=c++17'],
    meson_version: '>=1.6.0'
)

nb = dependency('nanobind', static: false)
ct = dependency('CUDAToolkit')

py = import('python').find_installation('python')
py.extension_module(
    '_C',
    sources : [
        'csrc/mod.cpp',
        'csrc/example.h',
        'csrc/example.cpp',
        'csrc/example.cu',
    ],
    dependencies : [ct, nb],
    limited_api : '3.13',
)
