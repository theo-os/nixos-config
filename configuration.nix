{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./modules/networking.nix
    ./modules/neovim.nix
  ];

  nix.channel.enable = false;
  nixpkgs.overlays = [
    inputs.nix-tree-rs.overlays.default
  ];

  boot.kernelParams = [ "net.ifnames=-1" ];
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
      "dynamic-derivations"
      "recursive-nix"
      "blake3-hashes"
    ];
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

  users.users = {
    root.hashedPassword = "!";

    theo = {
      isNormalUser = true;
      description = "Theo";
      extraGroups = [
        "networkmanager"
        "wheel"
        "kvm"
        "adbusers"
        "libvirtd"
      ];
      shell = pkgs.nushell;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0xE9o3tB6RkWRwbQTq1afsJ5uqJCaFlvyi8RvYcZAO"
      ];
    };
  };

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
    libarchive
    uutils-coreutils-noprefix
    nix-output-monitor
    libarchive
    uutils-coreutils-noprefix
    watchman
    wireguard-tools
    qemu
  ];

  services.mullvad-vpn.enable = true;

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
