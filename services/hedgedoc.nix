{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    80
    443
  ];

  sops.templates."hedgedoc.env" = {
    content = ''
      CMD_EMAIL = false
      CMD_ALLOW_EMAIL_REGISTER = false
      CMD_ALLOW_FREEURL = true
      CMD_REQUIRE_FREEURL_AUTHENTICATION = true
      CMD_ALLOW_ANONYMOUS = false

      # LDAP
      CMD_LDAP_URL="ldap://127.0.0.1:3890"
      CMD_LDAP_BINDDN="uid=admin,ou=people,dn=fstn,dn=top"
      CMD_LDAP_BINDCREDENTIALS="${config.sops.placeholder."lldap/admin"}"
      CMD_LDAP_SEARCHBASE="ou=people,dn=fstn,dn=top"
      CMD_LDAP_SEARCHFILTER="(&(objectClass=person)(uid={{username}}))"
      CMD_LDAP_USERIDFIELD="uid"
      CMD_LDAP_PROVIDERNAME="HAL"
    '';
    owner = config.users.users.hedgedoc.name;
  };

  users.users.hedgedoc = {
    isSystemUser = true;
  };
  services.hedgedoc = {
    enable = true;
    settings = {
      host = "127.0.0.1";
      db = {
        username = "hedgedoc";
        database = "hedgedoc";
        host = "/run/postgresql";
        dialect = "postgresql";
      };
      domain = "pad.fstn.top";
      port = 8271;
      protocolUseSSL = true;
      allowOrigin = [ "pad.fstn.top" ];
    };
    environmentFile = "${config.sops.templates."hedgedoc.env".path}";
  };

  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;
    virtualHosts."pad.fstn.top" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.hedgedoc.settings.port}";
      };
      locations."/socket.io/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.hedgedoc.settings.port}";
        proxyWebsockets = true;
        extraConfig = "proxy_ssl_server_name on;";
      };
    };
  };

  services.internal.postgresql = {
    ensureDatabases = [ "hedgedoc" ];
    ensureUsers = [
      {
        name = "hedgedoc";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type    database    DBuser    auth-method
      local    hedgedoc    hedgedoc  peer
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pasha@fstn.top";
  };
}
