{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80 443];

  users.users.hedgedoc = {
    isSystemUser = true;
  };
  services.hedgedoc = {
    enable = true;
    settings = {
      host = "127.0.0.1";
      db = {
        username = "hedgedoc";
        databse = "hedgedoc";
        host = "/run/postgresql";
        dialect = "postgresql";
      };
      domain = "pad.hal.com";
      port = 8271;
      allowOrigin = ["pad.hal.com"];
    };
  };

  users.users.nginx.extraGroups = ["acme"];
  services.nginx = {
    enable = true;
    virtualHosts."pad.hal.com" = {
      enableACME = false;
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.hedgedoc.settings.port}";
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["hedgedoc"];
    ensureUsers = [
      {
        name = "hedgedoc";
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
