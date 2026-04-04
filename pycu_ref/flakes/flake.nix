{
    description = "dev shell for devbox_test";

    nixConfig = {
        extra-substituters = [ "https://nix-community.cachix.org" ];
        extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };

    inputs = {
        nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
        flake-schemas.url = github:DeterminateSystems/flake-schemas;
        nix-gl-host.url = "github:numtide/nix-gl-host";
    };

    outputs = { self, flake-schemas, nixpkgs, nix-gl-host }:
    let

        pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            config.cudaSupport = true;
        };

        buildDeps = with pkgs; [
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

        devDeps = with pkgs; buildDeps ++ [
            # to find .so paths that expose the host cuda driver
            nix-gl-host.defaultPackage.x86_64-linux
            # python packages are installed and managed by this nix-pkg uv
            uv
            # uv should link this nix-pkg of python312 into the project .venv
            python312
            # numpy system dep
            zlib
        ];

        # $(nixglhost -p) finds .so paths that expose the host cuda driver (so gpus can be detected by torch)
        # ${stdenv.cc.cc.lib}/lib provides system stdlibs to unpatched python pkgs managed by uv (like libstdc++.so for torch._C)
        # ${lib.makeLibraryPath packages} provides system deps to unpatched python pkgs managed by uv (like libz.so for numpy)
        devHook = with pkgs; ''
            echo "DEV SHELL FOR: devbox_test"
            echo "UV SYNC"
            # uv sync --no-install-workspace
            uv sync
            echo "VENV ACTIVATE"
            . .venv/bin/activate
            echo "UV VENV: $VIRTUAL_ENV"
            echo "LOAD ENV"
            export LD_LIBRARY_PATH=$(nixglhost -p):$LD_LIBRARY_PATH
            export LD_LIBRARY_PATH="${lib.makeLibraryPath devDeps}:$LD_LIBRARY_PATH"
            export LD_LIBRARY_PATH="${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
            export Torch_DIR=$(python -c 'import torch; print(torch.utils.cmake_prefix_path)')
            export pybind11_DIR=$(python -c 'import pybind11; print(pybind11.get_cmake_dir())')
            unset PYTHONPATH && export UV_PYTHON_DOWNLOADS=never
        '';

        devShell = pkgs.mkShell rec {
            inherit devDeps devHook;
            buildInputs = devDeps;
            shellHook = devHook;
        };

    in
    {
        schemas = flake-schemas.schemas;
        devShells.x86_64-linux.default = devShell;
    };
}
