{ config, pkgs, util, ... }:
{
  programs.neovim = {
    # Essentials
    extraPackages = with pkgs; [
      clang-tools
      lua-language-server
      nil
    ];

    plugins = with pkgs.vimPlugins; [
      lazydev-nvim

      # LSP
      {
       plugin = nvim-lspconfig;
       config = util.toLuaFile ../lua/lsp.lua;
      }
      rustaceanvim

      # Cmp
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      friendly-snippets
      {
        plugin = nvim-cmp;
	config = util.toLuaFile ../lua/cmp.lua;
      }

      # Formatter
      { 
        plugin = conform-nvim;
        config = util.toLuaFile ../lua/formatter.lua;
      }
    ];
  };
}
