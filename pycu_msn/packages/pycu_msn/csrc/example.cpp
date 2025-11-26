#include <torch/extension.h>

#include <vector>


namespace pycu_msn {

std::vector<torch::Tensor> myfn_cpu(
    torch::Tensor input
){
    return {input, input+1};
}

}

TORCH_LIBRARY_IMPL(pycu_msn, CPU, m) {
    m.impl("myfn", &pycu_msn::myfn_cpu);
}
TORCH_LIBRARY(pycu_msn, m) {
    m.def("myfn(Tensor input) -> Tensor[]");
}


