{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.internal.backup;
  dbBackupPath = "/var/backup/psql";
in
{
  options.services.internal.backup.serviceNames =
    with lib;
    mkOption {
      type = types.listOf types.str;
    };

  options.services.internal.backup.dbNames =
    with lib;
    mkOption {
      type = types.listOf types.str;
    };

  config = {
    services.borgbackup.jobs.services = {
      paths = [
        "/var"
      ];
      exclude = [
        "/var/cache"
      ];
      encryption.mode = "none";

      # /backup is btrfs labeled as BACKUP. see ./hardware-configuration.nix
      repo = "/backup";

      compression = "auto,zstd";
      startAt = "daily";

      readWritePaths = [
        dbBackupPath
      ];

      preHook = ''
        set -e
        systemctl stop ${lib.concatStringsSep " " cfg.serviceNames}

        # dump database
        mkdir -p /tmp/pg-dump/
        for db in ${lib.concatStringsSep " " cfg.dbNames}; do
            ${pkgs.util-linux}/bin/runuser -u postgres -- ${pkgs.postgresql}/bin/pg_dump -Fc $db > /tmp/pg-dump/$db.dump
        done

        mv /tmp/pg-dump/* ${dbBackupPath};
      '';

      postHook = ''
        systemctl restart ${lib.concatStringsSep " " cfg.serviceNames}
        rmdir /tmp/pg-dump
      '';
    };

    systemd.tmpfiles.settings = {
      backup = {
        # Redundant to the `UMask` service config setting on new installs, but installs made in
        # early 24.11 created world-readable media storage by default, which is a privacy risk. This
        # fixes those installs.
        "${dbBackupPath}" = {
          d = {
            user = "root";
            group = "root";
            mode = "0700";
          };
        };
      };
    };
  };
}
