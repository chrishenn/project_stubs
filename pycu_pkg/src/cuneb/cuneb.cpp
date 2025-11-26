#include <torch/script.h>

#include <vector>
#include <string>


#define CHECK_CUDA(x) AT_ASSERTM(x.is_cuda(), #x " must be a CUDA tensor")
#define CHECK_CONTIGUOUS(x) AT_ASSERTM(x.is_contiguous(), #x " must be contiguous")
#define CHECK_INPUT(x) CHECK_CUDA(x); CHECK_CONTIGUOUS(x)


std::vector<torch::Tensor> call(
        torch::Tensor pts,
        torch::Tensor imgid,

        torch::Tensor lin_radius,
        torch::Tensor scale_radius,

        torch::Tensor batch_size
);


std::vector<torch::Tensor> call_wrapper(
        torch::Tensor pts,
        torch::Tensor imgid,

        torch::Tensor lin_radius,
        torch::Tensor scale_radius,

        torch::Tensor batch_size
    )
{

    CHECK_INPUT(pts);
    CHECK_INPUT(imgid);
    CHECK_INPUT(batch_size);
    CHECK_INPUT(lin_radius);
    CHECK_INPUT(scale_radius);

    return call(
        pts,
        imgid,

        lin_radius,
        scale_radius,

        batch_size
    );
}

//////
// Hardcode project names here. MOD_NAME and cuneb_ops cannot be created programmatically (cannot parse from file)

// MOD_NAME in the .env file
const static char* MOD_NAME = "cuneb";

// OPS_NAME in the .env file
TORCH_LIBRARY(cuneb_ops, m)
{
    m.def(MOD_NAME, call_wrapper);
}
