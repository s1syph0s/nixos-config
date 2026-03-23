local ts = require('nvim-treesitter')

-- 1. Install parsers (Replaces ensure_installed in setup)
-- This is now an async call; typically used in your plugin manager's 'build' or 'config'
ts.install({
  -- Add your languages here, e.g., "lua", "python", "javascript"
})

-- 2. Core Treesitter Settings
-- The legacy .configs.setup is deprecated; use the top-level setup for internal paths
ts.setup({
  install_dir = nil, -- Use default
})

-- 3. Enable Highlighting and Indent
-- In 2026, it is recommended to enable these via autocommands or 
-- the new vim.treesitter.start() API for better performance.
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    local ok, _ = pcall(vim.treesitter.start)
    if ok then
      -- Treesitter successfully started for this buffer
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter.indent'.get_indent()"
    end
  end,
})

-- 4. Incremental Selection
-- This remains part of the nvim-treesitter core for now
--require('nvim-treesitter.incremental_selection').setup({
--  enable = true,
--  keymaps = {
--    init_selection = '<c-space>',
--    node_incremental = '<c-space>',
--    node_decremental = '<M-space>',
--    scope_incremental = '<c-s>',
--  },
--})

-- 5. Text Objects (Requires nvim-treesitter-textobjects plugin)
-- This has been decoupled into its own setup call
require('nvim-treesitter-textobjects').setup({
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ['aa'] = '@parameter.outer',
      ['ia'] = '@parameter.inner',
      ['af'] = '@function.outer',
      ['if'] = '@function.inner',
      ['ac'] = '@class.outer',
      ['ic'] = '@class.inner',
    },
  },
  move = {
    enable = true,
    set_jumps = true,
    goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
    goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
    goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
    goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
  },
  swap = {
    enable = true,
    swap_next = { ['<leader>a'] = '@parameter.inner' },
    swap_previous = { ['<leader>A'] = '@parameter.inner' },
  },
})
