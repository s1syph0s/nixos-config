{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sisyph0s";
  home.homeDirectory = "/home/sisyph0s";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  fonts.fontconfig.enable = true;

  imports = [
    ./home/neovim
    ./home/tmux
    ./home/hyprland
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    neofetch

    # archives
    zip
    unzip

    # utils
    ripgrep
    jq
    fzf

    dolphin

    # networking tools
    nmap

    # misc
    file
    which
    tree
    gnupg

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

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" "SourceCodePro" ]; })

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

    # hyprland config TODO: Migrate to better solution
    # ".config/hypr" = {
    #   source = ./config/hypr;
    #   recursive = true;
    # };
    # waybar config TODO: Migrate to better solution
    ".config/waybar" = {
      source = ./config/waybar;
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
  };

  programs.lazygit.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";

      shell = "${pkgs.fish}/bin/fish";

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

  programs.fish = {
    enable = true;
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono NF:size=12";
	icon-theme = "Papirus-Dark";
	fuzzy = true;
	lines = 8;
	image-size-ratio=0.0;
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
  home.sessionVariables = {
    EDITOR = "nvim";
  };

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

  xdg.userDirs = let homeDir = config.home.homeDirectory; in {
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
