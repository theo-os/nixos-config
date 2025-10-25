{...}: {
  imports = [
    ./disks.nix
  ];

  networking = {
    defaultGateway = {
      address = "135.181.6.1";
      interface = "eth0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    interfaces = {
      eth0 = {
        ipv6.addresses = [
          {
            address = "2a01:4f9:4b:52ea::69";
            prefixLength = 64;
          }
        ];
        ipv4.addresses = [
          {
            address = "135.181.6.50";
            prefixLength = 26;
          }
        ];
      };
    };
  };
}
