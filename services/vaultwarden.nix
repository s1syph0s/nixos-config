{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80 443];

  sops.secrets = {
    "vault/admin" = {
      owner = config.users.users.vaultwarden.name;
    };
    "brevo/vault" = {
      owner = config.users.users.vaultwarden.name;
    };
  };

  sops.templates."vault.env" = {
    content = ''
      ADMIN_TOKEN="${config.sops.placeholder."vault/admin"}"
      SMTP_PASSWORD="${config.sops.placeholder."brevo/vault"}"
    '';
    owner = config.users.users.vaultwarden.name;
  };

  users.users.vaultwarden = {
    isSystemUser = true;
  };
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      # Refer to https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
      DOMAIN = "https://vault.fstn.top";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      DATABASE_URL = "postgresql:///vaultwarden";

      # This example assumes a mailserver running on localhost,
      # thus without transport encryption.
      # If you use an external mail server, follow:
      #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
      SMTP_HOST = "smtp-relay.brevo.com";
      SMTP_PORT = 587;

      SMTP_FROM = "admin-vault@fistanto.org";
      SMTP_FROM_NAME = "HAL Vault Admin";
      SMTP_USERNAME = "93ebc1001@smtp-brevo.com";
      SMTP_SECURITY = "starttls";
    };
    environmentFile = "${config.sops.templates."vault.env".path}";
  };

  users.users.nginx.extraGroups = ["acme"];
  services.nginx = {
    enable = true;
    virtualHosts."vault.fstn.top" = {
      enableACME = true;
      forceSSL = true;
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
      #type    database       DBuser       auth-method
      local    vaultwarden    vaultwarden  peer
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pasha@fstn.top";
  };
}
