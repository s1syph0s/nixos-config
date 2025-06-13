{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    hooks = {
      preNew = "mbsync --all";
    };
  };

  accounts.email = {
    accounts.ibr-tubs = {
      address = "fistanto@ibr.cs.tu-bs.de";
      imap = {
        host = "mail.ibr.cs.tu-bs.de";
        port = 993;
      };
      mbsync = {
        enable = true;
        create = "maildir";
        extraConfig.account = {
          AuthMechs = "PLAIN";
        };
      };
      msmtp.enable = true;
      notmuch.enable = true;
      primary = true;

      realName = "Pasha Alghifari Fistanto";
      userName = "fistanto";
      passwordCommand = "cat ~/.config/sops-nix/secrets/email/ibr";
      smtp = {
        host = "mail.ibr.cs.tu-bs.de";
        port = 587;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };
    };
  };
}
