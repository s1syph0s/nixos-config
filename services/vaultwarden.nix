{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80 443];

  users.users.vaultwarden = {
    isSystemUser = true;
  };
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      # Refer to https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
      DOMAIN = "https://vault.hal.com";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      DATABASE_URL = "postgresql:///vaultwarden";

      # This example assumes a mailserver running on localhost,
      # thus without transport encryption.
      # If you use an external mail server, follow:
      #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
      # SMTP_HOST = "127.0.0.1";
      # SMTP_PORT = 25;
      # SMTP_SSL = false;

      # SMTP_FROM = "admin@bitwarden.example.com";
      # SMTP_FROM_NAME = "example.com Bitwarden server";
    };
  };

  users.users.nginx.extraGroups = ["acme"];
  services.nginx = {
    enable = true;
    virtualHosts."vault.hal.com" = {
      enableACME = false;
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["vaultwarden"];
    ensureUsers = [
      {
        name = "vaultwarden";
	ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     peer
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pasha@fstn.top";
  };
}
