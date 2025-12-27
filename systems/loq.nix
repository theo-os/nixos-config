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
  # FIXME: zed has issues with niri: https://github.com/YaLTeR/niri/issues/2335
  # nixpkgs.config.allowUnfreePredicate =
  #   pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "nvidia-x11"
  #     "nvidia-settings"
  #   ];
  # hardware.nvidia = {
  #   open = true;
  #   modesetting.enable = true;
  #   powerManagement.enable = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.production;
  # };
  # services.xserver.videoDrivers = [ "nvidia" ];

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
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "i915.enable_dpcd_backlight=1"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a36f0b52-c13b-4587-8ecf-b20e0b60f29a";
    fsType = "btrfs";
    options = [
      "compress=zstd:6"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/551C-5CEC";
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
