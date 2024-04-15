{
  description = "pre-commit in docker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit = {
      url = "github:slimslenderslacks/pre-commit";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
  };

  outputs = { self, nixpkgs, flake-utils, devshell, pre-commit }:

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
            devshell.overlays.default
            (self: super: {
              pre-commit = pre-commit.packages."${system}";
            })
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };

        in
        rec {

          packages.default = pkgs.pre-commit.default;
          devShells.default = pkgs.mkShell {
            name = "python";
            nativeBuildInputs = with pkgs;
              let
                devpython = pkgs.python39.withPackages
                  (packages: with packages; [ virtualenv pip setuptools wheel requests python-dotenv pathspec tiktoken pytest ]);
              in
              [ devpython ];
          };
        });
}
