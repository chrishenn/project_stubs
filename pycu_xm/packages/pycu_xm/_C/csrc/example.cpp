#include <torch/extension.h>
#include <vector>


namespace pycu_xm {

std::vector<torch::Tensor> myfn_cpu(
    torch::Tensor input
){
    return {input, input+1};
}

}

TORCH_LIBRARY_IMPL(pycu_xm, CPU, m) {
    m.impl("myfn", &pycu_xm::myfn_cpu);
}
TORCH_LIBRARY(pycu_xm, m) {
    m.def("myfn(Tensor input) -> Tensor[]");
}


