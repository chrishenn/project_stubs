#include <torch/script.h>
#include <torch/torch.h>

auto main() -> int {
	std::string model_path = "./resnet18.pt";
	auto module = torch::jit::load(model_path);
	module.dump(false, false, false);

	return 0;
}
