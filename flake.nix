{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/pull/387469/head";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations = {
        macbookair71 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./systems/macbookair71.nix
          ];
        };

        bigmac = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./systems/bigmac.nix
            ./apple-silicon-support/default.nix
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

        iso =
          (nixpkgs.lib.genAttrs [
            "aarch64-linux"
            "x86_64-linux"
          ])
            (
              system:
              nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = {
                  inherit inputs;
                };
                modules = [
                  ./configuration.nix
                  "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
                  "${nixpkgs}/nixos/modules/profiles/minimal.nix"
                  (
                    { lib, config, ... }:
                    {
                      nixpkgs.crossSystem.system = system;
                      isoImage.edition = lib.mkOverride 500 "minimal";
                      boot.supportedFilesystems.zfs = lib.mkForce false;

                      # Broadcom wifi
                      nixpkgs.config.allowUnfree = true;
                      boot.kernelModules = [ "wl" ];
                      boot.initrd.kernelModules = [
                        "wl"
                      ];
                      boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
                      boot.blacklistedKernelModules = [
                        "b43"
                        "bcma"
                      ];
                    }
                  )
                ];
              }
            );
      };
    };
}
