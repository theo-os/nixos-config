{
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
  ];

  boot.kernelPackages = pkgs.linuxPackages_testing;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];

    trusted-substituters = [
      "https://hydra.nixos.org"
      "https://cache.garnix.io"
    ];

    trusted-public-keys = [
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  fonts.packages = [
    (pkgs.nerd-fonts.jetbrains-mono)
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji
  ];

  boot.supportedFilesystems = [
    "bcachefs"
    "btrfs"
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.wireless = {
    enable = true;
    dbusControlled = false;
    userControlled.enable = true;
  };

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

  services.xserver.enable = false;

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = false;
    pulse.enable = true;
    jack.enable = true;
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
    ];
    shell = pkgs.nushell;
    packages = with pkgs; [
      floorp
      servo
      alacritty
      ffmpeg
      blender
      niri
      fuzzel
      vesktop
      prismlauncher
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
    nixfmt-rfc-style
    nil
    nix-output-monitor
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
  };

  nix.optimise = {
    automatic = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  services.openssh.enable = true;
  programs.gnupg = {
    agent.enable = true;
  };

  services.kanata = {
    enable = true;
  };

  networking.firewall.enable = true;

  system.stateVersion = "24.11";
}
