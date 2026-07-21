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
  ];

  nix.channel.enable = false;
  nixpkgs.overlays = [
  ];
  nixpkgs.config.problems.handlers = {
    bcachefs.broken = "ignore";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.theo = import ./home/theo.nix;

  nixpkgs.config.allowUnfree = true;

  # buck2 moment
  systemd.services."user@".serviceConfig.Delegate = "memory pids cpu cpuset";

  virtualisation.incus.enable = true;
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.proxy_ndp" = 1;
    "net.ipv6.conf.default.proxy_ndp" = 1;
  };
  networking.nftables.enable = true;
  services.ndppd = {
    enable = true;
    proxies.wlp8s0 = {
      interface = "wlp8s0";
      rules = {
        "2600:1700:b770:7840::/64" = {
          method = "static";
        };
      };
    };
  };

  boot.kernelParams = [ "net.ifnames=-1" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "hx";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  nix.settings = {
    experimental-features = [
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
      "https://cache.numtide.com"
    ];

    trusted-public-keys = [
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  fonts.packages = with pkgs; [
    monocraft
    miracode
    noto-fonts
    noto-fonts-color-emoji
  ];

  boot.supportedFilesystems = [
    "bcachefs"
    "f2fs"
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
          "incus-admi"
          "networkmanager"
          "wheel"
          "kvm"
          "adbusers"
          "dialout"
          "uucp"
        ];
        shell = pkgs.fish;
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

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    dnsmasq
    bat
    gitoxide
    gitMinimal
    jujutsu
    uutils-coreutils-noprefix
    ripgrep
    helix
    zellij
    skim
    sd
    fd
    hyperfine
    starship
    btop
    wpa_supplicant
    dhcpcd
    iw
    nixd
    nixfmt
    libarchive
    wireguard-tools
    qemu
    llama-cpp-vulkan
    difftastic
    fastfetch
    tokei
  ];

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
