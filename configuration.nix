{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  nix.channel.enable = false;
  nixpkgs.overlays = [
    inputs.nix.overlays.default
  ];

  boot.zfs = {
    package = pkgs.zfs_unstable;
  };
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  programs.niri.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "parallel-eval"
      "ca-derivations"
    ];
    eval-cores = 0;
    trusted-users = [
      "root"
      "@wheel"
    ];

    trusted-substituters = [
      "https://hydra.nixos.org"
    ];

    trusted-public-keys = [
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    ];
  };

  fonts.packages = [
    pkgs.monocraft
    pkgs.miracode
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji
  ];

  boot.supportedFilesystems = [
    "btrfs"
    "zfs"
  ];
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    alsa.support32Bit = false;
    jack.enable = false;
  };

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  users.users.theo = {
    isNormalUser = true;
    description = "Theo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
    ];
    shell = pkgs.nushell;
    packages = with pkgs; [
      firefox
      alacritty
      ffmpeg
      blender
      legcord
    ];
  };

  environment.systemPackages = with pkgs; [
    youki
    gnupg
    bat
    nushell
    helix
    gitoxide
    gitMinimal
    jujutsu
    uutils-coreutils-noprefix
    ripgrep
    skim
    sd
    fd
    hyperfine
    starship
    zoxide
    zellij
    btop
    fastfetch
    wpa_supplicant
    dhcpcd
    iw
    nixd
    nix-output-monitor
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "zstd";
  };

  nix.optimise = {
    automatic = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  services.openssh.enable = true;

  services.kanata = {
    enable = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
  ];

  system.stateVersion = lib.mkDefault lib.trivial.release;
}
