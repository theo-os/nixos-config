{
  config,
  lib,
  ...
}:
{
  imports = [
    ../modules/desktop.nix
  ];
  nix.settings.max-jobs = 12;

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
    device = "/dev/disk/by-uuid/b9685104-b8bf-4bf7-9919-d161f56f484f";
    fsType = "bcachefs";
    options = [
      "compress=zstd:9"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/977D-0452";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.localSystem.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
