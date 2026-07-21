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
    ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = true;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
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
    device = "/dev/disk/by-uuid/05c926f7-55eb-445c-b585-84abe3b0b1c2";
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E1DB-54BE";
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
