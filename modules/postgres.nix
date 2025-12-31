{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.internal.postgresql;
in

{
  options.services.internal.postgresql = {
    authentication =
      with lib;
      mkOption {
        type = types.lines;
        default = "";
      };

    ensureDatabases =
      with lib;
      mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Ensures that the specified databases exist.
          This option will never delete existing databases, especially not when the value of this
          option is changed. This means that databases created once through this option or
          otherwise have to be removed manually.
        '';
        example = [
          "gitea"
          "nextcloud"
        ];
      };

    ensureUsers =
      with lib;
      mkOption {
        default = [ ];
      };
  };

  config.services.postgresql = {
    enable = true;
    ensureDatabases = [ "root" ] ++ cfg.ensureDatabases;
    ensureUsers = [
      {
        name = "root";
        ensureDBOwnership = true;
      }
    ]
    ++ cfg.ensureUsers;
    authentication = pkgs.lib.mkOverride 10 ''
      #type    database         DBuser         auth-method
      local    all              root           peer
      local    postgres         postgres       peer

      ${cfg.authentication}
    '';
  };
}
