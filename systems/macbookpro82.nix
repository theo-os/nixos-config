{
  config,
  lib,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "firewire_ohci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [
    "kvm-intel"
    "wl"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/754b7522-e33b-4a38-af74-b71d301b69f6";
    fsType = "btrfs";
    options = [ "compress=zstd:6" "subvol=@" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/98B2-5247";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/8d87f174-04ab-4616-9051-784e35558e1f"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
