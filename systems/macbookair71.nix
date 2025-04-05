{
  config,
  lib,
  ...
}:

{
  nix.settings.max-jobs = 1;

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
    "wl"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/bd84243e-78e7-4874-96f5-b133f5d08111";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:6"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/AFB6-0B4D";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/c8a5fe80-8789-4d9a-9ed1-9b8f9c1e2346"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.config.allowUnfree = true;

  hardware.facetimehd.enable = true;

  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
  ];
}
