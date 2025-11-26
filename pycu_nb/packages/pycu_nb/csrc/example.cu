#include <cuda.h>
#include <cuda_runtime.h>

#include <vector>
#include <cassert>
#include <iostream>

#include <nanobind/ndarray.h>

#include "example.h"


namespace nb = nanobind;

using myarr_cu = nb::ndarray<int, nb::c_contig, nb::ndim<1>, nb::device::cuda>;
using mytorch_cu = nb::ndarray<nb::pytorch, int, nb::c_contig, nb::ndim<1>, nb::device::cuda>;


inline void cuassert(const bool success)
{
    if(!success) {
        fprintf(stderr, "CUDA failed with '%s'\n", cudaGetErrorString(cudaGetLastError()));
    }
    assert(success);
}

namespace pycu_nb {
    __global__ void example_k(
        const int* input,
        int* output,
        const size_t size
    )
    {
        for(size_t glob_i = blockIdx.x * blockDim.x + threadIdx.x; glob_i < size; glob_i += blockDim.x * gridDim.x) {
            output[glob_i] = input[glob_i] - 1;
        }
    }

    mytorch_cu myfn_gpu(const myarr_cu& input)
    {
        // allocate an output tensor
        cudaSetDevice(input.device_id());

        size_t n = 1;
        for(size_t i = 0; i < input.ndim(); i++) {
            n *= input.shape(i);
        }
        auto data = static_cast<int*>(malloc(n * sizeof(int)));
        nb::capsule owner(data, [](void* p) noexcept {
            free(p);
        });
        auto output = mytorch_cu(data, {input.shape(0)}, owner);

        // calculate grid size
        cudaDeviceProp deviceProp {};
        cudaGetDeviceProperties(&deviceProp, input.device_id());
        size_t n_threads = 256;
        size_t full_cover = (input.shape(0) - 1) / n_threads + 1;
        size_t n_blocks = std::min(full_cover, 2 * static_cast<size_t>(deviceProp.multiProcessorCount));

        const dim3 blocks(n_blocks);
        const dim3 threads(n_threads);

        example_k<<<blocks, threads>>>(
            input.data(),
            output.data(),
            output.shape(0)
        );
        cuassert(cudaDeviceSynchronize() == cudaSuccess);
        return output;
    }
}
