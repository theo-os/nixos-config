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
    device = "/dev/disk/by-uuid/86b3333f-fce2-4fad-83d7-3b21f2111cdc";
    fsType = "btrfs";
    options = [ "compress=zstd:6" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/07D8-5AEA";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/bb368060-b7ad-4234-af30-44d727821018"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
