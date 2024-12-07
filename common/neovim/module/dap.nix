{ config, pkgs, util, ... }:
{
  programs.neovim = {
    extraPackages = with pkgs; [
      delve
    ];
    extraLuaConfig = ''
      ${builtins.readFile ../lua/dap.lua}
    '';

    plugins = with pkgs.vimPlugins; [
      nvim-dap
      nvim-nio
      nvim-dap-go
      nvim-dap-ui
    ];
  };
}
