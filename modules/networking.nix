{...}: {
  services.kresd.enable = true;
  services.resolved.enable = false;
  networking.nameservers = ["::1"];

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    networkmanager.wifi.powersave = false;
    firewall.enable = true;
    firewall.allowedTCPPorts = [
      22
      80
      443
      25565
    ];
    firewall.allowedUDPPorts = [
      443
    ];
  };
}
