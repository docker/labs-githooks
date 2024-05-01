
{
  description = "The Docker LSP";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # can't update graal right now - this is from Aug '23
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    go-linguist.url = "github:slimslenderslacks/go-linguist";
    go-linguist.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, devshell, ...}@inputs:

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
            devshell.overlays.default
            (self: super: {
              go-linguist = inputs.go-linguist.packages."${system}";
            })
          ];
          # don't treat pkgs as meaning nixpkgs - treat it as all packages!
          pkgs = import nixpkgs {
            inherit overlays system;
          };

        in rec
        {
          scripts = pkgs.stdenv.mkDerivation {
            name = "scripts";
            src = ./.;
            installPhase = ''
              mkdir -p $out/resources
              cp -R . $out
              cp init.clj $out
            '';
          };
          entrypoint = pkgs.writeShellScriptBin "entrypoint" ''
            cd ${scripts}
            ${pkgs.babashka}/bin/bb init.clj /project
          '';
          packages = rec {
            default = pkgs.buildEnv {
              name = "install";
              paths = [
                pkgs.go-linguist.app
                pkgs.coreutils
                entrypoint
              ];
            };
          };

          devShells.default = pkgs.devshell.mkShell {
            name = "lsp";
            packages = with pkgs; [ babashka clojure ];

            commands = [
            ];
          };
        });
}
