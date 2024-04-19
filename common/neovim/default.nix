{ config, pkgs, ... }:

let
  util = import ./util.nix {};
in 
{
  imports = [
    ./module/lsp.nix
  ];
  _module.args.util = util;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      wl-clipboard
      ripgrep
      fzf
    ];

    plugins = with pkgs.vimPlugins; [
      {
          plugin = kanagawa-nvim;
          config = util.toLua "vim.cmd.colorscheme 'kanagawa'";
      }

      vim-tmux-navigator

      vim-sleuth

      {
        plugin = comment-nvim;
	    config = util.toLua ''require('Comment').setup()'';
      }
      {
        plugin = which-key-nvim;
	    config = util.toLua ''require('which-key').setup()'';
      }

      {
        plugin = fidget-nvim;
        config = util.toLua ''require('fidget').setup()'';
      }

      {
        plugin = gitsigns-nvim;
        config = util.toLua ''
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
        config = util.toLua ''
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
        config = util.toLua ''
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
        config = util.toLuaFile ./lua/telescope.lua;
      }

      nvim-treesitter-textobjects
      nvim-treesitter-context
      {
        plugin = (nvim-treesitter.withPlugins (p: with p; [
          nix
          lua
        ]));
        config = util.toLuaFile ./lua/treesitter.lua;
      }
      {
        plugin = oil-nvim;
        config = util.toLua ''
          require('oil').setup()
          vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open oil' })
        '';
      }
      {
        plugin = neo-tree-nvim;
        config = util.toLua ''
          vim.keymap.set('n', '\\', '<CMD>Neotree toggle<CR>', { desc = 'Toggle tree' })
          require('neo-tree').setup({
            window = {
              position = 'right'
            }
          })
        '';
      }
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
    '';
  };
}
