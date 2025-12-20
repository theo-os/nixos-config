{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    systems.url = "github:nix-systems/default";
  };

  nixConfig = {
    extra-trusted-substituters = [
      "https://hydra.nixos.org"
      "https://cache.tinted.dev"
      "https://cache.garnix.io"
    ];

    extra-trusted-public-keys = [
      "cache.tinted.dev:HbSI/UAU9rer8jmEkMoiWWzEoyta92rLsUnQ9K6KTLA="
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs =
    {
      nixpkgs,
      systems,
      ...
    }@inputs:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
      nixosConfigurations = {
        rpi4 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./systems/rpi4.nix
          ];
        };

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

        pyro = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./systems/pyro
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
