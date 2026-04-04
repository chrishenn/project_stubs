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

        inherit (pkgs.lib) attrsets lists strings trivial;
        inherit (pkgs.cudaPackages) cudaFlags cudnn nccl;

        buildDeps = with pkgs; [
            cmake
            ninja
            hatch
            python312Packages.torch
            python312Packages.hatchling
            python312Packages.hatch-vcs
            cudaPackages.cudatoolkit
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

        nativeBuildDeps = with pkgs; [
            cmake
            ninja
            hatch
            removeReferencesTo
            autoAddDriverRunpath
            python312Packages.pybind11
            python312Packages.torch
            python312Packages.hatchling
            python312Packages.hatch-vcs
            cudaPackages.cuda_nvcc
        ];

        deps = with pkgs; [
            # system cuda/cpp build deps
            cmake
            ninja
            cudaPackages.cudatoolkit
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
        # undo the dependency leakage done by Nixpkgs Python infrastructure.
        hook = with pkgs; ''
            echo "DEV SHELL FOR: devbox_test"
            echo "UV SYNC"
            uv sync
            echo "VENV ACTIVATE"
            . .venv/bin/activate
            echo "UV VENV: $VIRTUAL_ENV"
            echo "LOAD ENV"
            export LD_LIBRARY_PATH=$(nixglhost -p):$LD_LIBRARY_PATH
            export LD_LIBRARY_PATH="${lib.makeLibraryPath deps}:$LD_LIBRARY_PATH"
            export LD_LIBRARY_PATH="${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
            export Torch_DIR=$(python -c 'import torch; print(torch.utils.cmake_prefix_path)')
            unset PYTHONPATH && export UV_PYTHON_DOWNLOADS=never
        '';

        myshell = pkgs.mkShell rec {
            inherit deps hook;

            packages = deps;
            shellHook = hook;
        };

        supportedTorchCudaCapabilities = let
            real = [
              "8.0"
              "8.6"
              "8.7"
              "8.9"
              "9.0"
              "9.0a"
            ];
            ptx = lists.map (x: "${x}+PTX") real;
          in
          real ++ ptx;

        supportedCudaCapabilities = lists.intersectLists cudaFlags.cudaCapabilities supportedTorchCudaCapabilities;
        unsupportedCudaCapabilities = lists.subtractLists supportedCudaCapabilities cudaFlags.cudaCapabilities;

        gpuArchWarner =
          supported: unsupported:
          trivial.throwIf (supported == [ ]) (
            "No supported GPU targets specified. Requested GPU targets: "
            + strings.concatStringsSep ", " unsupported
          ) supported;

        gpuTargetString = strings.concatStringsSep ";" (gpuArchWarner supportedCudaCapabilities unsupportedCudaCapabilities);

        mypkg = with pkgs; python312Packages.buildPythonPackage rec {
            inherit deps hook gpuTargetString buildDeps;

            dontUseCmakeConfigure = true;
            cmakeFlags = [
                (lib.cmakeFeature "CUDAToolkit_VERSION" cudaPackages.cudaVersion)
                (lib.cmakeFeature "CMAKE_CUDA_COMPILER_TOOLKIT_VERSION" cudaPackages.cudaVersion)
            ];

            preBuild = ''
                export MAX_JOBS=$NIX_BUILD_CORES
                ${pkgs.cmake}/bin/cmake ./packages/read_row/src/read_row/csrc -G Ninja
                ninja
            '';

            preConfigure = ''
                export TORCH_CUDA_ARCH_LIST="${gpuTargetString}"
                export CUPTI_INCLUDE_DIR=${lib.getDev cudaPackages.cuda_cupti}/include
                export CUPTI_LIBRARY_DIR=${lib.getLib cudaPackages.cuda_cupti}/lib
                export CUDNN_INCLUDE_DIR=${lib.getLib cudnn}/include
                export CUDNN_LIB_DIR=${cudnn.lib}/lib
            '';

            postInstall = ''
                ls "$out"
            '';

            buildInputs = buildDeps;
            nativeBuildInputs = nativeBuildDeps;

            format = "wheel";
            dontStrip = true;
            pname = "read_row";
            version = "0.1.0";
            src = self;
            outputs = [ "out" ];
            pyproject = true;
            build-system = [ pkgs.python312Packages.hatchling ];
            meta = {
                platforms = lib.platforms.linux;
                license = lib.licenses.mit;
            };
        };

    in
    {
        schemas = flake-schemas.schemas;
        devShells.x86_64-linux.default = myshell;
        packages.x86_64-linux.default = mypkg;
    };
}
