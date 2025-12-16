{ pkgs, ... }:
let
  domain = "tinted.dev";
  adminEmail = "admin@tinted.dev";

  keycloakPort = 8080;
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.postgresql.enable = true;

  services.zitadel = {
    enable = true;
    openFirewall = true;

    tlsMode = "external";
    settings = {
      Port = 39995;
      ExternalPort = 443;
      ExternalDomain = "id.${domain}";
      Database = {
        postgres = {
          Host = "localhost";
          Port = 5432;
          Database = "zitadel";
          MaxOpenConns = 15;
          MaxIdleConns = 10;
          MaxConnLifetime = "1h";
          MaxConnIdleTime = "5m";
        };
      };
    };
  };

  services.harmonia = {
    enable = true;
    signKeyPaths = [ "/var/lib/secrets/harmonia.secret" ];
    settings.enable_compression = true;
    settings.bind = "unix:/run/harmonia/socket";
  };

  security.acme.defaults.email = adminEmail;
  security.acme.acceptTerms = true;

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;
    recommendedTlsSettings = true;
    virtualHosts."id.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;
      http3 = true;

      extraConfig = ''
        proxy_pass http://localhost:39995";
        proxy_redirect http:// https://;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

    virtualHosts."cache.${domain}" = {
      enableACME = true;
      forceSSL = true;
      quic = true;
      http3 = true;
      extraConfig = ''
        proxy_pass http://unix:/run/harmonia/socket;
        proxy_redirect http:// https://;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}
