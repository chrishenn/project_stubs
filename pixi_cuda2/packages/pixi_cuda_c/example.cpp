#include <torch/extension.h>

#include <vector>


namespace ns {

std::vector<torch::Tensor> myfn_cpu(
    torch::Tensor input
){
    return {input, input+1};
}

}

TORCH_LIBRARY_IMPL(ns, CPU, m) {
    m.impl("myfn", &ns::myfn_cpu);
}
TORCH_LIBRARY(ns, m) {
    m.def("myfn(Tensor input) -> Tensor[]");
}
