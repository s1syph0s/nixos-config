{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.pointerCursor = {
    name = "Capitaine Cursors (Nord)";
    package = pkgs.capitaine-cursors-themed;
    size = 24;
  };
  gtk.cursorTheme = {
    name = "Capitaine Cursors (Nord)";
    package = pkgs.capitaine-cursors-themed;
    size = 24;
  };
  fonts.fontconfig.enable = true;

  imports = [
    ./neovim
    ./emacs
    ./tmux
    ./hyprland
    ./waybar
    ./zellij
    ./email
    ./rofi
    ./niri
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    fastfetch
    btop

    # archives
    zip
    unzip

    # utils
    ripgrep
    fd
    coreutils
    jq
    fzf
    tealdeer

    kdePackages.dolphin

    # networking tools
    nmap

    # misc
    file
    which
    tree
    ausweisapp

    # system call monitoring
    strace
    ltrace
    lsof

    # system tools
    sysstat
    lm_sensors
    pciutils
    usbutils

    # desktop utils
    swaybg
    grim
    slurp
    hyprpicker

    gimp3
    wl-clipboard

    papirus-icon-theme

    pavucontrol
    coppwr

    # pdf
    kdePackages.okular
    pdftk

    # img viewer
    qimgv

    kdePackages.kservice

    vesktop

    mangohud
    goverlay

    espup
    cargo-generate

    deploy-rs

    thunderbird
    qbittorrent

    # multimedia
    vlc

    hello

    cmake
    gcc
    libtool

    trezor-suite

    # chat
    irssi
    element-desktop
    telegram-desktop
    signal-desktop

    spotify

    # custom packages
    hypr-kblayout

    sqlite

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    nerd-fonts.jetbrains-mono
    nerd-fonts.sauce-code-pro
    nerd-fonts.symbols-only
    nerd-fonts.iosevka

    just

    xournalpp
    wl-mirror
    opentabletdriver

    via

    # LSP
    gopls
    clang-tools
    lua-language-server
    nixd
    tinymist

    hledger

    # Formatter
    alejandra
    nixfmt-rfc-style
    rustfmt

    xwayland-satellite

    # Debugger
    gdb

    # Resesarch
    zotero

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".ssh/config".force = true;
  };

  home.activation.fixSshConfigPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run mkdir -p "$HOME/.ssh"
    run chmod 700 "$HOME/.ssh"

    if [ -L "$HOME/.ssh/config" ]; then
      src="$(readlink -f "$HOME/.ssh/config")"
      if [ -f "$src" ]; then
        run rm -f "$HOME/.ssh/config"
        run install -m600 "$src" "$HOME/.ssh/config"
      fi
    fi
  '';

  # VCS
  programs.git = {
    enable = true;
    userName = "Pasha Fistanto";
    userEmail = lib.mkDefault "pasha@fstn.top";
    # extraConfig = {
    #   sendemail = {
    #     smtpServer = "127.0.0.1";
    #     smtpUser = "pasha@fstn.top";
    #     smtpEncryption = "tls";
    #     smtpServerPort = 1025;
    #     smtpSSLCertPath = "";
    #   };
    # };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Pasha Fistanto";
        email = lib.mkDefault "pasha@fstn.top";
      };
    };
  };

  programs.lazygit.enable = true;

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      command = "${pkgs.zsh}/bin/zsh";

      font-family = "SauceCodePro NF Medium";
      # theme = "kanagawabones";
      font-style = "Regular";
      font-family-bold = "SauceCodePro NF";
      font-style-bold = "Bold";
      font-family-italic = "SauceCodePro NF";
      font-style-italic = "Italic";
      font-family-bold-italic = "SauceCodePro NF";
      font-style-bold-italic = "Bold Italic";
      font-size = 11;

      background-opacity = 0.95;
      window-decoration = false;
      confirm-close-surface = false;

      shell-integration-features = "no-cursor";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";

      terminal.shell = "${pkgs.fish}/bin/fish";

      font = {
        size = 11;

        bold = {
          family = "SauceCodePro NF";
          style = "Bold";
        };
        bold_italic = {
          family = "SauceCodePro NF";
          style = "Bold Italic";
        };
        italic = {
          family = "SauceCodePro NF";
          style = "Italic";
        };
        normal = {
          family = "SauceCodePro NF Medium";
          style = "Regular";
        };
      };
    };
    theme = "ayu_mirage";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

      # launch fish
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey '^F' forward-char
      bindkey '^B' backward-char

      export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
    '';
    shellAliases = {
      ls = "ls --color";
      ll = "ls -l";
      lal = "ls -al";
      cat = "bat";
      lg = "lazygit";
      ".." = "cd ..";
    };

    # prezto adds $HOME/bin to path
    prezto = {
      enable = true;
      caseSensitive = false;
      prompt.theme = "pure";
      syntaxHighlighting.highlighters = [ "main" ];
      utility.safeOps = false;
      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "spectrum"
        "utility"
        "completion"
        "autosuggestions"
        "syntax-highlighting"
        "prompt"
      ];
    };
  };
  home.file.".p10k.zsh".source = ./bin/.p10k.zsh;
  home.file."bin/hledger.sh".source = ./bin/hledger.sh;

  programs.fish = {
    enable = true;
    shellAbbrs = {
      lg = "lazygit";
      lal = "ls -al";
    };
    shellAliases = {
      cat = "bat";
    };
    plugins = [
      # {
      #   name = "tide";
      #   src = pkgs.fishPlugins.tide.src;
      # }
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf.src;
      }
    ];
    interactiveShellInit = ''
      set -U fish_user_paths ~/.emacs.d/bin $fish_user_paths
      export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

      set -U __done_notify_sound 1

      fish_add_path ~/bin

      # pure cfg
      set -U pure_enable_nixdevshell true
      set -U pure_symbol_nixdevshell_prefix "󱄅 "
      set -U pure_show_subsecond_command_duration true
    '';
  };

  me.niri = {
    enable = true;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sisyph0s/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # wayland.windowManager.hyprland = {
  #   enable = true;
  # };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 0;
        hide_cursor = true;
      };

      background = [
        {
          path = "~/media/img/wallpaper-moebius.png";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 1;
          placeholder_text = "<i>Password...</i>";
          shadow_passes = 1;
          rounding = 8;
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof hyprlock || hyprlock";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono 8";
      anchor = "top-center";
      background-color = "#2e3440";
      height = 50;
      margin = "5";
      padding = "0,5,10";
      border-size = 2;
      border-color = "#88c0d0";
      border-radius = 15;
      max-icon-size = 32;
      default-timeout = 5000;
      "urgency=normal" = {
        border-color = "#d08770";
      };
      "urgency=high" = {
        border-color = "#bf616a";
        default-timeout = 0;
      };
    };
  };

  programs.bat = {
    enable = true;
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "p.fistanto@pm.me";
      pinentry = pkgs.pinentry-tty;
    };
  };

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    matchBlocks."*".addKeysToAgent = "yes";
  };

  programs.man.generateCaches = true;

  systemd.user.tmpfiles.rules = [
    "#Type Path                                     Mode User Group Age         Argument"
    "d     %h/tmp                                   700  -    -     7d          -"
  ];

  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    configPackages = [ pkgs.niri ];
  };
  xdg.userDirs =
    let
      homeDir = config.home.homeDirectory;
    in
    {
      enable = true;
      createDirectories = true;

      desktop = null;
      templates = null;
      publicShare = null;

      documents = "${homeDir}/doc";
      download = "${homeDir}/tmp";
      music = "${homeDir}/media/music";
      pictures = "${homeDir}/media/img";
      videos = "${homeDir}/media/video";
    };
  xdg.configFile = {
    # HACK: For some reason the `kdePackages.kservice` package doesn't provide `applications.menu`. Take it from somewhere!
    "menus/applications.menu".text =
      builtins.readFile "${pkgs.libsForQt5.kservice}/etc/xdg/menus/applications.menu";
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "x-scheme-handler/discord" = [ "vesktop.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/pdf" = [ "okularApplication_pdf.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
    };
    associations.added = {
      "application/pdf" = [ "okularApplication_pdf.desktop" ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
