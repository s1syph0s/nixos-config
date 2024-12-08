{ config, pkgs, util, ... }:
{
  programs.neovim = {
    extraLuaConfig = ''
      ${builtins.readFile ../lua/bookmarks.lua}
    '';

    plugins = with pkgs.vimPlugins; [
      grapple-nvim
    ];
  };
}
