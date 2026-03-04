{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # FIXME: wasmtime is borked: https://github.com/DeterminateSystems/nix-src/pull/333
    determinate-nix = {
      url = "github:DeterminateSystems/nix-src/2a57a000c3c849339d9b5c6239dba070040784e1";
      inputs.nixpkgs-regression.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        ...
      }:
      {
        imports = [
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "riscv64-linux"
        ];
        flake = {
          nixosConfigurations = {
            gigamachine = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit inputs;
              };
              modules = [
                ./configuration.nix
                ./systems/gigamachine.nix
              ];
            };

            loq = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit inputs;
              };
              modules = [
                ./configuration.nix
                ./systems/loq.nix
              ];
            };

            deply = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit inputs;
              };
              modules = [
                ./configuration.nix
                ./systems/deply
              ];
            };

            iso = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit inputs;
              };
              modules = [
                ./configuration.nix
                "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
                "${nixpkgs}/nixos/modules/profiles/installation-device.nix"
                "${nixpkgs}/nixos/modules/profiles/minimal.nix"
                (
                  { lib, ... }:
                  {
                    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
                    isoImage.edition = lib.mkOverride 500 "minimal";
                  }
                )
              ];
            };
          };
        };

        perSystem =
          { pkgs, ... }:
          {
            formatter = pkgs.nixfmt;
          };
      }
    );
}
