{
  lib,
  ...
}:

{
  boot.initrd.availableKernelModules = [ "usb_storage" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  hardware.asahi.peripheralFirmwareDirectory = ../firmware;
  hardware.asahi.useExperimentalGPUDriver = true;

  fileSystems."/" = {
    device = "UUID=d538714c-dbef-4f04-9a45-13f0ec99f845";
    fsType = "bcachefs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/016E-1E1E";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
