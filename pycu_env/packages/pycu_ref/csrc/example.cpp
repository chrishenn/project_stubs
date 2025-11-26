#include <torch/extension.h>

#include <vector>


namespace pycu_ref {

std::vector<torch::Tensor> myfn_cpu(
    torch::Tensor input
){
    return {input, input+1};
}

}

TORCH_LIBRARY_IMPL(pycu_ref, CPU, m) {
    m.impl("myfn", &pycu_ref::myfn_cpu);
}
TORCH_LIBRARY(pycu_ref, m) {
    m.def("myfn(Tensor input) -> Tensor[]");
}
