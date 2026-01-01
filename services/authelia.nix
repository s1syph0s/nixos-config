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
    "brevo/auth" = {
      owner = "authelia-main";
    };
    "auth/jwt_secret" = {
      owner = "authelia-main";
    };
    "auth/storage_key" = {
      owner = "authelia-main";
    };
    "auth/session_secret" = {
      owner = "authelia-main";
    };
    "auth/hmac" = {
      owner = "authelia-main";
    };
    "auth/jwk/private" = {
      owner = "authelia-main";
    };
  };

  users.groups.brevo = { };
  users.users."authelia-main" = {
    extraGroups = [ "brevo" ];
  };

  sops.templates."auth.yml" =
    let
      host = config.services.lldap.settings.ldap_host;
      port = config.services.lldap.settings.ldap_port;
    in
    {
      owner = "authelia-main";
      content = ''
        theme: "dark"

        server:
          address: "tcp://127.0.0.1:9091"

        identity_validation:
          reset_password:
            jwt_lifespan: "5 minutes"
            jwt_algorithm: "HS256"

        identity_providers:
          oidc:
            ## The other portions of the mandatory OpenID Connect 1.0 configuration go here.
            ## See: https://www.authelia.com/c/oidc

            enable_client_debug_messages: false
            minimum_parameter_entropy: 8
            enforce_pkce: "public_clients_only"
            enable_pkce_plain_challenge: false
            enable_jwt_access_token_stateless_introspection: false
            discovery_signed_response_alg: "none"
            discovery_signed_response_key_id: ""
            require_pushed_authorization_requests: false
            authorization_policies:
              policy_name:
                default_policy: "two_factor"
                rules:
                  - networks:
                      - "10.100.0.0/24"
            lifespans:
              access_token: "1h"
              authorize_code: "1m"
              id_token: "1h"
              refresh_token: "90m"
            cors:
              endpoints:
                - "authorization"
                - "token"
                - "revocation"
                - "introspection"

            clients:
              - client_id: "aVw64VQIUS6IrthBknSmGdj3Nmw4ZRuGujf3lKrO8arIUvtQ-9RapQG7KNAb733EcZ77stvq"
                client_name: "immich"
                client_secret: "$pbkdf2-sha512$310000$7NOPNON4nTgo1gPwG2BY1A$M8w8YIvXFtsiZMxJByZP8MTukZJVD.wlLHJgIPEPbjiRnmIaeiev7FzY7z8GU3xrJtZ95hm1iAjmhcUvWjD8Ew"
                authorization_policy: "two_factor"
                redirect_uris:
                  - "https://photos.fstn.top/auth/login"
                  - "https://photos.fstn.top/user-settings"
                  - "app.immich:///oauth-callback"
                scopes:
                  - "openid"
                  - "profile"
                  - "email"
                response_types:
                  - "code"
                grant_types:
                  - "authorization_code"
                access_token_signed_response_alg: "RS256"
                userinfo_signed_response_alg: "RS256"
                token_endpoint_auth_method: "client_secret_post"

        authentication_backend:
          refresh_interval: "5m"
          password_reset:
            disable: false
            custom_url: ""
          password_change:
            disable: false
          ldap:
            implementation: "lldap"
            address: "ldap://${host}:${toString port}"
            base_dn: "dn=fstn,dn=top"
            user: "uid=admin,ou=people,dn=fstn,dn=top"
            password: "${config.sops.placeholder."lldap/admin"}"

        storage:
          postgres:
              address: "/run/postgresql"
              servers: []
              database: "authelia-main"
              schema: "public"
              username: "authelia-main"
              timeout: "5s"

        session:
          cookies:
            - domain: "fstn.top"
              authelia_url: "https://auth.fstn.top"

        notifier:
          smtp:
            address: "smtp://smtp-relay.brevo.com:587"
            username: "93ebc1001@smtp-brevo.com"
            password: "${config.sops.placeholder."brevo/auth"}"
            sender: "HAL Auth Admin <admin-auth@fistanto.org>"

        access_control:
          rules:
          - domain: "auth.fstn.top"
            policy: "bypass"
      '';
    };

  services.internal.backup = {
    serviceNames = [
      "authelia-main"
    ];
    dbNames = [
      "authelia-main"
    ];
  };

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = "${config.sops.secrets."auth/jwt_secret".path}";
      oidcHmacSecretFile = "${config.sops.secrets."auth/hmac".path}";
      oidcIssuerPrivateKeyFile = "${config.sops.secrets."auth/jwk/private".path}";
      sessionSecretFile = "${config.sops.secrets."auth/session_secret".path}";
      storageEncryptionKeyFile = "${config.sops.secrets."auth/storage_key".path}";
    };
    settingsFiles = [
      "${config.sops.templates."auth.yml".path}"
    ];
  };

  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;
    virtualHosts."auth.fstn.top" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9091";
      };
    };
  };

  services.internal.postgresql = {
    ensureDatabases = [ "authelia-main" ];
    ensureUsers = [
      {
        name = "authelia-main";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type    database         DBuser         auth-method
      local    authelia-main    authelia-main  peer
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pasha@fstn.top";
  };
}
