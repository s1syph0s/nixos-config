{ config, pkgs, util, ... }:
{
  programs.neovim = {
    # Essentials
    extraPackages = with pkgs; [
      clang-tools
      lua-language-server
    ];

    extraLuaConfig = ''
      ${builtins.readFile ../lua/lsp.lua}
      ${builtins.readFile ../lua/cmp.lua}
      ${builtins.readFile ../lua/formatter.lua}
    '';

    plugins = with pkgs.vimPlugins; [
      lazydev-nvim

      # LSP
      nvim-lspconfig
      rustaceanvim

      # Cmp
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      friendly-snippets
      nvim-cmp

      # Formatter
      conform-nvim
    ];
  };
}
