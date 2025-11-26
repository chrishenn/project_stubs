#include <torch/extension.h>

#include <cuda.h>
#include <cuda_runtime.h>

#include <vector>
#include <math.h>
#include <stdio.h>
#include <iostream>


namespace pycu_skit {

__global__ void example_k(
    const int* input,
          int* output,
    const int size
){
    for (int glob_i = blockIdx.x * blockDim.x + threadIdx.x; glob_i < size; glob_i += blockDim.x * gridDim.x)
    {
        auto in_num = input[glob_i];
        output[glob_i] = in_num - 1;
    }
}

std::vector<torch::Tensor> myfn_cu(
    torch::Tensor input
) {

    // torch::indexing gives us advanced slicing support
    using namespace torch::indexing;

    // set device to match input tensor
    auto device = input.get_device();
    cudaSetDevice(device);

    // allocate an output tensor
    auto int_opt = torch::TensorOptions()
            .dtype(torch::kInt32)
            .layout(torch::kStrided)
            .device(torch::kCUDA, device)
            .requires_grad(false);

    auto output = torch::empty(input.size(0), int_opt);

    // calculate grid size
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, device);
    int n_threads = 256;
    int sms = deviceProp.multiProcessorCount;
    int full_cover = (input.size(0)-1) / n_threads + 1;
    int n_blocks = min(full_cover, 2 * sms);

    const dim3 blocks(n_blocks);
    const dim3 threads(n_threads);

    example_k<<<blocks, threads>>>(
        input.data_ptr<int>(),
        output.data_ptr<int>(),
        output.size(0)
    );
    return {input, output};
}

}

TORCH_LIBRARY_IMPL(pycu_skit, CUDA, m) {
  m.impl("myfn", &pycu_skit::myfn_cu);
}
