{ config, pkgs, util, ... }:
{
  programs.neovim = {
    extraLuaConfig = ''
      ${builtins.readFile ../lua/options.lua}
    '';
  };
}
