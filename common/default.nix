{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
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
    ./zellij
  ];
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    fastfetch

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

    dolphin

    # networking tools
    nmap

    # misc
    file
    which
    tree

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

    btop

    wl-clipboard

    papirus-icon-theme

    pavucontrol
    coppwr

    # pdf
    okular
    pdftk

    vesktop

    mangohud
    gamemode
    goverlay

    espup
    cargo-generate

    fishPlugins.tide
    fishPlugins.done

    thunderbird
    qbittorrent

    # multimedia
    vlc

    cmake
    gcc
    libtool

    # chat
    irssi
    element-desktop
    telegram-desktop

    # utils
    nix-index

    # custom packages
    hypr-kblayout

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    nerd-fonts.jetbrains-mono
    nerd-fonts.sauce-code-pro
    nerd-fonts.symbols-only

    # LSP
    gopls
    rust-analyzer
    clang-tools
    lua-language-server
    nixd

    # Formatter
    alejandra

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

    # waybar config TODO: Migrate to better solution
    ".config/waybar" = {
      source = ../config/waybar;
      recursive = true;
    };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.git = {
    enable = true;
    userName = "Pasha Fistanto";
    userEmail = "pasha@fstn.top";
    extraConfig = {
      sendemail = {
        smtpServer = "127.0.0.1";
        smtpUser = "pasha@fstn.top";
        smtpEncryption = "tls";
        smtpServerPort = 1025;
        smtpSSLCertPath = "";
      };
    };
  };

  programs.lazygit.enable = true;

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command = "${pkgs.fish}/bin/fish";

      font-family = "SauceCodePro NF Medium";
      theme = "kanagawabones";
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

      window.opacity = 0.9;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh.enable = true;
  programs.nushell.enable = true;

  programs.fish = {
    enable = true;
    shellAbbrs = {
      lg = "lazygit";
      lal = "ls -al";
    };
    shellAliases = {cat = "bat";};
    interactiveShellInit = ''
      set -U fish_user_paths ~/.emacs.d/bin $fish_user_paths
      set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
      set -x MANROFFOPT "-c"

      set -U __done_notify_sound 1
    '';
  };

  programs.anyrun = {
    enable = true;
    config = {
      plugins = [
        # An array of all the plugins you want, which either can be paths to the .so files, or their packages
        inputs.anyrun.packages.${pkgs.system}.applications
      ];
      x = {fraction = 0.5;};
      y = {fraction = 0.3;};
      width = {fraction = 0.3;};
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = false;
      showResultsImmediately = false;
      maxEntries = null;
    };
    extraCss = ''
      /* GTK Vars */
      @define-color bg-color #313244;
      @define-color fg-color #cdd6f4;
      @define-color primary-color #89b4fa;
      @define-color secondary-color #cba6f7;
      @define-color border-color @primary-color;
      @define-color selected-bg-color @primary-color;
      @define-color selected-fg-color @bg-color;

      * {
        all: unset;
        font-family: JetBrainsMono Nerd Font;
      }

      #window {
        background: transparent;
      }

      box#main {
        border-radius: 16px;
        background-color: alpha(@bg-color, 0.6);
        border: 0.5px solid alpha(@fg-color, 0.25);
      }

      entry#entry {
        font-size: 1.25rem;
        background: transparent;
        box-shadow: none;
        border: none;
        border-radius: 16px;
        padding: 16px 24px;
        min-height: 40px;
        caret-color: @primary-color;
      }

      list#main {
        background-color: transparent;
      }

      #plugin {
        background-color: transparent;
        padding-bottom: 4px;
      }

      #match {
        font-size: 1.1rem;
        padding: 2px 4px;
      }

      #match:selected,
      #match:hover {
        background-color: @selected-bg-color;
        color: @selected-fg-color;
      }

      #match:selected label#info,
      #match:hover label#info {
        color: @selected-fg-color;
      }

      #match:selected label#match-desc,
      #match:hover label#match-desc {
        color: alpha(@selected-fg-color, 0.9);
      }

      #match label#info {
        color: transparent;
        color: @fg-color;
      }

      label#match-desc {
        font-size: 1rem;
        color: @fg-color;
      }

      label#plugin {
        font-size: 16px;
      }
    '';

    extraConfigFiles."applications.ron".text = ''
      Config(
        // Also show the Desktop Actions defined in the desktop files, e.g. "New Window" from LibreWolf
        desktop_actions: true,
        max_entries: 5,
        // The terminal used for running terminal based desktop entries, if left as `None` a static list of terminals is used
        // to determine what terminal to use.
        terminal: Some("ghostty"),
      )
    '';
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono NF:size=12";
        icon-theme = "Papirus-Dark";
        fuzzy = true;
        lines = 8;
        image-size-ratio = 0.0;
      };
      colors = {
        background = "080808aa";
        text = "dddddddd";
        match = "8db678dd";
      };
    };
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
  home.sessionVariables = {EDITOR = "nvim";};

  # wayland.windowManager.hyprland = {
  #   enable = true;
  # };

  programs.waybar.enable = true;

  services.mako = {
    enable = true;
    font = "JetBrainsMono 8";
    output = "DP-1";
    anchor = "top-center";
    backgroundColor = "#2e3440";
    height = 50;
    margin = "5";
    padding = "0,5,10";
    borderSize = 2;
    borderColor = "#88c0d0";
    borderRadius = 15;
    maxIconSize = 32;
    defaultTimeout = 5000;
    extraConfig = ''
      [urgency=normal]
      border-color=#d08770

      [urgency=high]
      border-color=#bf616a
      default-timeout=0
    '';
  };

  programs.bat = {enable = true;};

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "proxy.lab.sra" = {
        hostname = "lab.sra.uni-hannover.de";
        user = "pas.fistanto";
      };
      "lab.sra" = {
        hostname = "lab-pc32";
        proxyJump = "proxy.lab.sra";
        user = "pas.fistanto";
      };
    };
  };

  xdg.userDirs = let
    homeDir = config.home.homeDirectory;
  in {
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
