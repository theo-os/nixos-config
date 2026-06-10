{
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
  boot.initrd.kernelModules = [
    "f2fs"
    "crc32c"
  ];
  boot.loader.limine.efiSupport = true;
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0af4c152-b8ef-4ae9-93b4-6e64536c7119";
    fsType = "f2fs";
    options = [
      "defaults"
      "compress_algorithm=zstd:6"
      "compress_chksum" # Verifies compressed block integrity
      "atgc" # Enables advanced adaptive garbage collection
      "gc_merge" # Asynchronous foreground garbage collection
      "lazytime" # Optimizes IO writes for timestamps
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0437-4661";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}
