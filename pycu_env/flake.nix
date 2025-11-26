{
    description = "dev shell";

    inputs = {
        nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem (system:
    let
        pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.cudaSupport = true;
        };

        shell = with pkgs; pkgs.mkShell {
            buildInputs = [
                uv
                cmake
                ninja
                cudaPackages.cudatoolkit
                cudaPackages.cuda_nvcc
                cudaPackages.cuda_cudart
                cudaPackages.cuda_cupti
                cudaPackages.cuda_nvrtc
                cudaPackages.cuda_nvtx
                cudaPackages.cudnn
                cudaPackages.libcublas
                cudaPackages.libcufft
                cudaPackages.libcurand
                cudaPackages.libcusolver
                cudaPackages.libcusparse
                cudaPackages.libnvjitlink
                cudaPackages.nccl
            ];
        };

    in
    {
        devShell = shell;
    });
}
