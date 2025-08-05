{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80 443];

  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2816;
    database = {
      createDB = false;
    };
    settings = {
      server.externalDomain = "https://photos.fstn.top";
    };
  };

  users.users.immich = {
    isSystemUser = true;
  };

  users.users.nginx.extraGroups = ["acme"];
  services.nginx = {
    enable = true;
    virtualHosts."photos.fstn.top" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["immich"];
    ensureUsers = [
      {
        name = "immich";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser  auth-method
      local  immich    immich  peer
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pasha@fstn.top";
  };
}
