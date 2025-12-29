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

  sops.secrets = {
    "oidc_clients/immich/id" = {
      owner = "immich";
    };
    "oidc_clients/immich/secret" = {
      owner = "immich";
    };
  };

  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2816;
    database = {
      createDB = false;
    };

    settings = {
      machineLearning = {
        urls = [
          "http://localhost:3003"
        ];
      };
      oauth = {
        enabled = true;
        autoLaunch = true;
        clientId._secret = config.sops.secrets."oidc_clients/immich/id".path;
        clientSecret._secret = config.sops.secrets."oidc_clients/immich/secret".path;

        issuerUrl = "https://auth.fstn.top"; # TODO: Don't hardcode
        defaultStorageQuota = 200;
        profileSigningAlgorithm = "RS256";
      };
      server = {
        externalDomain = "https://photos.fstn.top";
      };
    };
  };

  users.users.immich = {
    isSystemUser = true;
  };

  users.users.nginx.extraGroups = [ "acme" ];
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
    ensureDatabases = [ "immich" ];
    ensureUsers = [
      {
        name = "immich";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser    auth-method
      local  immich    immich    peer
      local  immich    postgres  peer
      local  postgres  postgres  peer
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pasha@fstn.top";
  };
}
