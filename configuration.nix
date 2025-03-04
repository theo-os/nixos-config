{
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
  ];

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
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.graphics.enable = true;

  users.users.theo = {
    isNormalUser = true;
    description = "Theo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "adbusers"
    ];
    shell = pkgs.nushell;
    packages = [
      pkgs.floorp
      pkgs.alacritty
      pkgs.ffmpeg-full
      pkgs.blender
      pkgs.niri
      pkgs.bemenu
    ];
  };

  environment.systemPackages = [
    pkgs.youki
    pkgs.bat
    pkgs.nushell
    pkgs.helix
    pkgs.gitoxide
    pkgs.gitMinimal
    pkgs.jujutsu
    pkgs.uutils-coreutils-noprefix
    pkgs.ripgrep
    pkgs.skim
    pkgs.sd
    pkgs.fd
    pkgs.hyperfine
    pkgs.zoxide
    pkgs.zellij
    pkgs.btop
    pkgs.wpa_supplicant
    pkgs.dhcpcd
    pkgs.iw
    pkgs.nixfmt-rfc-style
    pkgs.nil
    pkgs.brightnessctl
    pkgs.pciutils
    pkgs.usbutils
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

  services.kanata = {
    enable = true;
  };

  networking.firewall.enable = false;

  system.stateVersion = "24.11";
}
