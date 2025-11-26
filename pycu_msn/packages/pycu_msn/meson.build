project(
    'pycu_msn',
    ['c', 'cpp', 'cuda'],
    default_options: ['cpp_std=c++17'],
)

py = import('python').find_installation('python3.13')
ct = dependency('CUDAToolkit')

libtorch = subproject('libtorch')
libtorch_dep = libtorch.get_variable('libtorch_dep')

py.extension_module(
  '_C',
  sources: ['csrc/example.cpp', 'csrc/example.cu'],
  dependencies: [ct, libtorch_dep],
)
