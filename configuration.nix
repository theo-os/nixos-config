{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./modules/networking.nix
  ];

  nix.channel.enable = false;
  nixpkgs.overlays = [
    inputs.nix.overlays.default
  ];

  boot.kernelParams = [ "net.ifnames=-1" ];
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_testing;
  hardware.enableRedistributableFirmware = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "parallel-eval"
      "ca-derivations"
      "dynamic-derivations"
      "blake3-hashes"
    ];
    eval-cores = 0;
    trusted-users = [
      "root"
      "@wheel"
    ];

    accept-flake-config = true;
    auto-optimise-store = true;

    trusted-substituters = [
      "https://hydra.nixos.org"
      "https://cache.tinted.dev"
      "https://cache.garnix.io"
    ];

    trusted-public-keys = [
      "cache.tinted.dev:HbSI/UAU9rer8jmEkMoiWWzEoyta92rLsUnQ9K6KTLA="
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
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
  ];
  boot.loader.grub.enable = true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

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

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };

  users.users = {
    root.hashedPassword = "!";

    theo = {
      isNormalUser = true;
      description = "Theo";
      extraGroups = [
        "networkmanager"
        "wheel"
        "kvm"
        "libvirtd"
        "adbusers"
      ];
      shell = pkgs.nushell;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMONqauyyiKgkkjn6PTWxRp5nrHeo3w9X9NZ7UbFjRsY"
      ];
    };
  };

  programs.adb.enable = true;

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    dnsmasq
    bat
    nushell
    helix
    gitoxide
    gitMinimal
    jujutsu
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
    libarchive
    uutils-coreutils-noprefix
    wireguard-tools
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

  system.stateVersion = lib.mkDefault lib.trivial.release;
}
