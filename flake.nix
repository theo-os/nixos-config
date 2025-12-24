{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    mesa = {
      url = "git+https://gitlab.freedesktop.org/mesa/mesa";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://cache.garnix.io"
    ];

    extra-trusted-public-keys = [
      "cache.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "riscv64-linux"
        "aarch64-linux"
      ];
    in
    {
      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
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
}
