{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  networking.firewall.interfaces.wg0.allowedTCPPorts = [80 443];

  sops.secrets = {
    "lldap/admin" = {
      owner = "lldap";
      group = "lldap";
    };
    "lldap/jwt_secret" = {
      owner = "lldap";
      group = "lldap";
    };
  };

  users.users.lldap = {
    isSystemUser = true;
    group = "lldap";
  };

  users.groups.lldap = {};

  services.lldap = {
    enable = true;
    settings = {
      http_url = "https://accounts.fstn.top";
      http_host = "127.0.0.1";
      ldap_host = "127.0.0.1";
      ldap_port = 3890;
      ldap_base_dn = "dn=fstn,dn=top";
    };

    environment = {
      LLDAP_JWT_SECRET_FILE = config.sops.secrets."lldap/jwt_secret".path;
      LLDAP_LDAP_USER_PASS_FILE = config.sops.secrets."lldap/admin".path;
    };
  };

  systemd.services.lldap.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "lldap";
    Group = "lldap";
  };

  users.users.nginx.extraGroups = ["acme"];
  services.nginx = {
    enable = true;
    virtualHosts."accounts.fstn.top" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.lldap.settings.http_port}";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pasha@fstn.top";
  };
}
