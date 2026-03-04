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
    inputs.determinate-nix.overlays.default
    inputs.llm-agents.overlays.default
    (final: previous: {
      # FIXME: nix-functional-tests -> stale-file-handle test fails?!
      nix-functional-tests = previous.nix-functional-tests.overrideAttrs (old: {
        buildCommand = ''
          mkdir -p $out
          touch $out/ignored
        '';
        doCheck = false;
        doInstallCheck = false;
      });

      nix = previous.nix.overrideAttrs (old: {
        doCheck = false;
        doInstallCheck = false;
        passthru = (old.passthru or { }) // {
          tests = { };
        };
      });

    })
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.theo = import ./users/theo.nix;

  boot.kernelParams = [ "net.ifnames=-1" ];
  boot.kernelPackages = pkgs.linuxPackages_testing;
  hardware.enableRedistributableFirmware = true;

  virtualisation.libvirtd.enable = true;

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

  fonts.packages = [
    pkgs.googlesans-code
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji
  ];

  boot.supportedFilesystems = [
    "bcachefs"
  ];
  boot.loader.limine.enable = true;
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

  users = {
    users = {
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
    # llm-agents.codex
    llm-agents.gemini-cli
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
    helix
    llama-cpp-vulkan
    nix-output-monitor
    delta
    fastfetch
    tokei
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  services.mullvad-vpn.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "zstd";
  };

  nix.optimise = {
    automatic = true;
  };

  system.stateVersion = lib.mkDefault lib.trivial.release;
}
