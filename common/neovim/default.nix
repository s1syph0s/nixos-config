{ config, pkgs, ... }:

{
  programs.neovim = let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in
  {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # LSP
      lua-language-server
      nil

      wl-clipboard
      ripgrep
      fzf
    ];

    plugins = with pkgs.vimPlugins; [
      {
          plugin = kanagawa-nvim;
          config = toLua "vim.cmd.colorscheme 'kanagawa'";
      }

      vim-tmux-navigator

      vim-sleuth

      neodev-nvim
      {
       plugin = nvim-lspconfig;
       config = toLuaFile ./plugin/lsp.lua;
      }

      {
        plugin = comment-nvim;
	    config = toLua ''require('Comment').setup()'';
      }
      {
        plugin = which-key-nvim;
	    config = toLua ''require('which-key').setup()'';
      }

      # Lsp stuff
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      friendly-snippets
      {
        plugin = nvim-cmp;
	config = toLuaFile ./plugin/cmp.lua;
      }
      {
        plugin = fidget-nvim;
        config = toLua ''require('fidget').setup()'';
      }

      {
        plugin = gitsigns-nvim;
        config = toLua ''
          local gitsigns = require('gitsigns')
          gitsigns.setup({
            on_attach = function(bufnr)
              vim.keymap.set('n', '<leader>gp', gitsigns.prev_hunk,
                { buffer = bufnr, desc = '[G]o to [P]revious Hunk'})
              vim.keymap.set('n', '<leader>gn', gitsigns.next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk'})
              vim.keymap.set('n', '<leader>ph', gitsigns.preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk'})
            end,
          })
        '';
      }

      nvim-web-devicons
      {
        plugin = lualine-nvim;
        config = toLua ''
          require('lualine').setup {
            options = {
              icons_enabled = true,
              theme = 'auto',
            },
          }
        '';
      }

      {
        plugin = indent-blankline-nvim;
        config = toLua ''
          require('ibl').setup({
            indent = { char = '┊' },
            whitespace = { remove_blankline_trail = true },
          })
        '';
      }

      plenary-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      {
        plugin = telescope-nvim;
        config = toLuaFile ./plugin/telescope.lua;
      }

      nvim-treesitter-textobjects
      nvim-treesitter-context
      {
        plugin = (nvim-treesitter.withPlugins (p: with p; [
          nix
          lua
        ]));
        config = toLuaFile ./plugin/treesitter.lua;
      }
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
    '';
  };
}
