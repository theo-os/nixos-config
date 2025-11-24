{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    ../modules/desktop.nix
  ];

  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7c47b203-f880-4b5b-a22d-306f105bf479";
    fsType = "btrfs";
    options = ["subvol=@" "compress=zstd:9" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5451-F14E";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
