{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./modules/networking.nix
    ./modules/neovim.nix
  ];

  nix.channel.enable = false;
  nixpkgs.overlays = [
    inputs.determinate-nix.overlays.default
  ];
  nixpkgs.config.problems.handlers = {
    bcachefs.broken = "ignore";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.theo = import ./users/theo.nix;

  nixpkgs.config.allowUnfree = true;

  # buck2 moment
  systemd.services."user@".serviceConfig.Delegate = "memory pids cpu cpuset";

  boot.kernelParams = [ "net.ifnames=-1" ];
  boot.kernelPackages = pkgs.linuxPackages_testing;
  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.EDITOR = "hx";

  nix.settings = {
    lazy-trees = true;
    eval-cores = 0;

    experimental-features = [
      "parallel-eval"
      "nix-command"
      "flakes"
      "blake3-hashes"
      "ca-derivations"
      "dynamic-derivations"
      "recursive-nix"
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

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
  ];

  boot.supportedFilesystems = [
    "bcachefs"
    "xfs"
  ];
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  virtualisation.libvirtd.enable = true;

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

  users = {
    users = {
      theo = {
        isNormalUser = true;
        description = "Theo";
        extraGroups = [
          "libvirtd"
          "networkmanager"
          "wheel"
          "kvm"
          "adbusers"
          "dialout"
          "uucp"
        ];
        shell = pkgs.nushell;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMONqauyyiKgkkjn6PTWxRp5nrHeo3w9X9NZ7UbFjRsY"
        ];
      };
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
    nushell
    dnsmasq
    bat
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
    wpa_supplicant
    dhcpcd
    iw
    nixd
    nixfmt
    libarchive
    watchman
    wireguard-tools
    qemu
    watchman
    llama-cpp-vulkan
    nix-output-monitor
    delta
    fastfetch
    tokei
    claude-code-bin
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
  };

  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "lz4";
  };

  nix.optimise = {
    automatic = true;
  };

  system.stateVersion = lib.mkDefault lib.trivial.release;
}
