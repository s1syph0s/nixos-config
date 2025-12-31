{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  users.users.paperless = {
    isSystemUser = true;
  };
  services.paperless = {
    enable = true;
    settings = {
      PAPERLESS_DBENGINE = "postgresql";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;
    virtualHosts."paperless.hal.com" = {
      enableACME = false;
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}";
      };
    };
  };

  services.internal.postgresql = {
    ensureDatabases = [ "paperless" ];
    ensureUsers = [
      {
        name = "paperless";
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
