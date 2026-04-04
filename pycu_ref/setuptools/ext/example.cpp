#include <torch/extension.h>

#include <vector>


namespace ext {

    std::vector<torch::Tensor> myfn_cpu(
        torch::Tensor input
    ){
        return {input, input};
    }

    // Register _C as a Python extension module
    PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {
        m.def("myfn", &myfn_cpu, "custom pytorch operation 'myfn'");
    }

    // Define the operators
    TORCH_LIBRARY(ext, m) {
        m.def("myfn(Tensor input) -> tuple[Tensor, Tensor]");
    }

    TORCH_LIBRARY_IMPL(ext, CPU, m) {
      m.impl("myfn", &myfn_cpu);
    }

}
