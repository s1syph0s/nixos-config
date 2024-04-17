{ config, pkgs, ... }:
{
  programs.neovim = {
    # Essentials
    extraPackages = with pkgs; [
      lua-language-server
      nil
    ];

    plugins = with pkgs.vimPlugins; [
      neodev-nvim
      {
       plugin = nvim-lspconfig;
       config = toLuaFile ../lua/lsp.lua;
      }

      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      friendly-snippets
      {
        plugin = nvim-cmp;
	config = toLuaFile ../lua/cmp.lua;
      }
    ];
  };
}
