{
  description = "pre-commit in docker";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, flake-utils, devshell }:

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
            devshell.overlays.default
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };

          # pre_commit pypy package is not available in nixpkgs
          # lazy - this is first called _after_ we have the python-pkgs
          pre_commit = ps: ps.callPackage ./pre-commit.nix { };

          # docker-out-of-docker
          docker-client = pkgs.docker_24.override {
            clientOnly = true;
            buildxSupport = false;
            composeSupport = false;
          };

          # using buildkit will need this because frontends are pulled
          # from the client (not from the daemon)
          wrap-docker = pkgs.writeShellScriptBin "docker" ''
            export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            ${docker-client}/bin/docker $@
          '';
        in
        rec {

          # a python environment with pre_commit installed
          packages.python-env = pkgs.python39.withPackages
            (python-pkgs: [
              (pre_commit python-pkgs)
              python-pkgs.cfgv
              python-pkgs.identify
              python-pkgs.pyyaml
              python-pkgs.virtualenv
              python-pkgs.pip
              python-pkgs.setuptools
              python-pkgs.wheel
            ]);

          packages.default = pkgs.writeShellScriptBin "pre-commit" ''
            export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            cd /project
            export PATH=$PATH:${pkgs.lib.makeBinPath [pkgs.git wrap-docker]}
            ${packages.python-env}/bin/python -mpre_commit hook-impl \
                --config=/config/pre-commit-config.yaml \
                --hook-type=pre-commit \
                --hook-dir /config \
                -- "$@"
          '';

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
