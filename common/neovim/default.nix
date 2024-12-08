{ config, pkgs, ... }:

let
  util = import ./util.nix {};
in 
{
  imports = [
    ./module/dap.nix
    ./module/options.nix
    ./module/lsp.nix
  ];
  _module.args.util = util;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = ''
      ${builtins.readFile ./lua/telescope.lua}
      ${builtins.readFile ./lua/treesitter.lua}
      ${builtins.readFile ./lua/session-manager.lua}
      ${builtins.readFile ./lua/dashboard.lua}
    '';

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

      # UI
      nui-nvim
      nvim-notify
      {
        plugin = noice-nvim;
        config = util.toLua ''
          require("noice").setup({
            lsp = {
              -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
              override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
              },
            },
            -- you can enable a preset for easier configuration
            presets = {
              bottom_search = true, -- use a classic bottom cmdline for search
              command_palette = true, -- position the cmdline and popupmenu together
              long_message_to_split = true, -- long messages will be sent to a split
              inc_rename = false, -- enables an input dialog for inc-rename.nvim
              lsp_doc_border = false, -- add a border to hover docs and signature help
            },
          })
        '';
      }

      {
        plugin = mini-nvim;
        config = util.toLua ''
          require('mini.ai').setup { n_lines = 500 }
          require('mini.surround').setup()

          local statusline = require 'mini.statusline'
          statusline.setup { use_icons = vim.g.have_nerd_font }
          ---@diagnostic disable-next-line: duplicate-set-field
          statusline.section_location = function()
            return '%2l:%-2v'
          end
        '';
      }

      {
        plugin = which-key-nvim;
        config = util.toLua ''
          require('which-key').setup()
        '';
      }

      {
        plugin = fidget-nvim;
        config = util.toLua ''require('fidget').setup()'';
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
            sections = {
              lualine_x = {
                {
                  require("noice").api.statusline.mode.get,
                  cond = require("noice").api.statusline.mode.has,
                  color = { fg = "#ff9e64" },
                }
              },
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
            exclude = {
              filetypes = {
                "dashboard",
              }
            }
          })
        '';
      }

      plenary-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      telescope-nvim

      {
        plugin = todo-comments-nvim;
        config = util.toLua ''
          require('todo-comments').setup()
        '';
      }

      nvim-treesitter-textobjects
      nvim-treesitter-context
      (nvim-treesitter.withPlugins (p: with p; [
        tree-sitter-nix
        tree-sitter-lua
        tree-sitter-rust
        tree-sitter-go
        tree-sitter-c
        tree-sitter-cpp
      ]))
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

      # Git integration
      {
        plugin = neogit;
        config = util.toLua ''
          require('neogit').setup()
            vim.api.nvim_create_autocmd("User", {
              pattern = {
                "NeogitBranchCheckout",
                "NeogitStatusRefreshed",
              },
              callback = function()
                vim.cmd('checkt')
              end
            })
        '';
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
      diffview-nvim

      persistence-nvim

      dashboard-nvim
    ];
  };
}
