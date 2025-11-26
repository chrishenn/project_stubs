{
    description = "dev shell";

    inputs = {
        nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
        flake-schemas.url = github:DeterminateSystems/flake-schemas;
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, flake-utils, flake-schemas, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
    let
        pkgs = import nixpkgs {
            system = system;
            config.allowUnfree = true;
            config.cudaSupport = true;
        };

    in
    {
        schemas = flake-schemas.schemas;
        devShell = with pkgs; mkShell { buildInputs = [uv]; };
    });
}
