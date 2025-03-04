{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  nix.settings.max-jobs = 1;

  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "Wl"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d48361f4-f484-4a25-b76d-78f79064628b";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:6"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/952F-2763";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/22eb2eb1-5900-44c2-9025-00994103da51"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.config.allowUnfree = true;

  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
  ];
}
