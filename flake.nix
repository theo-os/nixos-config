{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nix-tree-rs = {
      url = "github:theoparis/nix-tree-rs/push-qzkvpquvslwl";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
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
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );
}
