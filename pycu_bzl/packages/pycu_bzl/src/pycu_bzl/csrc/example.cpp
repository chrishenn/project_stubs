#include <torch/extension.h>

#include <vector>


namespace pycu_skit {

std::vector<torch::Tensor> myfn_cpu(
    torch::Tensor input
){
    return {input, input+1};
}

}

TORCH_LIBRARY_IMPL(pycu_skit, CPU, m) {
    m.impl("myfn", &pycu_skit::myfn_cpu);
}
TORCH_LIBRARY(pycu_skit, m) {
    m.def("myfn(Tensor input) -> Tensor[]");
}
