{
  config,
  lib,
  ...
}:
{
  imports = [
    ../modules/desktop.nix
  ];
  nix.settings.max-jobs = 6;

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "uas"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/222b86f8-263f-4d75-8362-9c0c75383518";
    fsType = "btrfs";
    options = [
      "compress=zstd:6"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5483-38CB";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
