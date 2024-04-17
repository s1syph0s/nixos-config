{ config, pkgs, util, ... }:
{
  programs.neovim =
  {
    # Essentials
    extraPackages = with pkgs; [
      lua-language-server
      nil
    ];

    plugins = with pkgs.vimPlugins; [
      neodev-nvim
      {
       plugin = nvim-lspconfig;
       config = util.toLuaFile ../lua/lsp.lua;
      }

      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      friendly-snippets
      {
        plugin = nvim-cmp;
	config = util.toLuaFile ../lua/cmp.lua;
      }
    ];
  };
}
