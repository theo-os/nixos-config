{
  config,
  lib,
  ...
}:
{
  imports = [
    ../modules/desktop.nix
    # ../modules/llvm.nix
  ];

  nix.settings.max-jobs = 2;
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
    ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "uas"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.loader.limine.efiSupport = true;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "i915.enable_dpcd_backlight=1"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1f5000aa-40da-4477-9903-c801348fd1c9";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E7E7-BBD7";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = true;
  nixpkgs.hostPlatform.system = "x86_64-linux";
}
