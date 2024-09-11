local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

local unlinkgrp = vim.api.nvim_create_augroup(
  'UnlinkSnippetOnModeChange',
  { clear = true }
)

vim.api.nvim_create_autocmd('ModeChanged', {
  group = unlinkgrp,
  pattern = { 's:n', 'i:*' },
  desc = 'Forget the current snippet when leaving the insert mode',
  callback = function(evt)
    if
        luasnip.session
        and luasnip.session.current_nodes[evt.buf]
        and not luasnip.session.jump_active
    then
      luasnip.unlink_current()
    end
  end,
})

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.scroll_docs(4),
    ['<C-p>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-Space>'] = cmp.mapping(function(fallback)
      if not cmp.visible() then
        cmp.complete()
      elseif cmp.visible() then
        cmp.close()
      else
        fallback()
      end
    end, { 'i' }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<C-l>'] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { 'i', 's' }),
    ['<C-h>'] = cmp.mapping(function()
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}
