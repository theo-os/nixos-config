{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  nix.settings.max-jobs = 6;

  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "uas"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  networking.hostId = "a5cd4e1d";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0c0056a7-4145-4a1e-b1e7-5f50e4597941";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:9"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/554C-B702";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
