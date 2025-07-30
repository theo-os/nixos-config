{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    apple-silicon.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, apple-silicon, ... }@inputs:
    {
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

        m2-macbookpro = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./systems/m2-macbookpro.nix
            apple-silicon.nixosModules.default
          ];
        };

        macbookpro82 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./systems/macbookpro82.nix
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

        iso-apple-silicon = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            apple-silicon.nixosModules.default
            "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
            "${nixpkgs}/nixos/modules/profiles/installation-device.nix"
            "${nixpkgs}/nixos/modules/profiles/minimal.nix"
            (
              {
                lib,
                pkgs,
                config,
                ...
              }:
              {
                nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
                isoImage.edition = lib.mkOverride 500 "minimal";
                boot.supportedFilesystems.zfs = lib.mkForce false;

                boot.initrd.availableKernelModules = [ "usb_storage" ];
                boot.initrd.kernelModules = [ ];
                boot.kernelModules = [ ];
                boot.extraModulePackages = [ ];
                hardware.asahi.useExperimentalGPUDriver = true;

                hardware.enableAllFirmware = lib.mkForce false;
                services.pulseaudio.enable = false;
                hardware.asahi.setupAsahiSound = false;

                console.packages = [ pkgs.terminus_font ];
                isoImage.makeEfiBootable = true;
                isoImage.squashfsCompression = "zstd -Xcompression-level 6";
                boot.postBootCommands =
                  let
                    inherit (config.hardware.asahi.pkgs) asahi-fwextract;
                  in
                  ''
                    for o in $(</proc/cmdline); do
                      case "$o" in
                        live.nixos.passwd=*)
                          set -- $(IFS==; echo $o)
                          echo "nixos:$2" | ${pkgs.shadow}/bin/chpasswd
                          ;;
                      esac
                    done

                    echo Extracting Asahi firmware...
                    mkdir -p /tmp/.fwsetup/{esp,extracted}

                    mount /dev/disk/by-partuuid/`cat /proc/device-tree/chosen/asahi,efi-system-partition` /tmp/.fwsetup/esp
                    ${asahi-fwextract}/bin/asahi-fwextract /tmp/.fwsetup/esp/asahi /tmp/.fwsetup/extracted
                    umount /tmp/.fwsetup/esp

                    pushd /tmp/.fwsetup/
                    cat /tmp/.fwsetup/extracted/firmware.cpio | ${pkgs.cpio}/bin/cpio -id --quiet --no-absolute-filenames
                    mkdir -p /lib/firmware
                    mv vendorfw/* /lib/firmware
                    popd
                    rm -rf /tmp/.fwsetup
                  '';
                hardware.asahi.extractPeripheralFirmware = false;
              }
            )
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
              { lib, config, ... }:
              {
                nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
                isoImage.edition = lib.mkOverride 500 "minimal";
                boot.supportedFilesystems.zfs = lib.mkForce false;
              }
            )
          ];
        };
      };
    };
}
