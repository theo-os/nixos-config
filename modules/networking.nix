{ ... }:
{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    networkmanager.wifi.powersave = false;
    firewall.enable = false;
    firewall.allowedTCPPorts = [
      22
      80
      443
      25565
    ];
    firewall.allowedUDPPorts = [
      443
    ];
    nftables.enable = true;
  };
}
