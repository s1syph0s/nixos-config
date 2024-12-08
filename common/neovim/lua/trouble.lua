require("trouble").setup()


local nmap = function(keys, func, desc)
  if desc then
    desc = 'Trouble: ' .. desc
  end

  vim.keymap.set('n', keys, func, { desc = desc })
end

nmap('<leader>dx', "<cmd>Trouble diagnostics toggle<cr>", 'Diagnostics')
nmap('<leader>dX', "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", 'Buffer Diagnostics')
nmap('<leader>cs', "<cmd>Trouble symbols toggle focus=false<cr>", 'Symbols')
nmap('<leader>cl', "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
  'LSP Definitions / references / ...')
nmap('<leader>dL', "<cmd>Trouble loclist toggle<cr>", 'Location List')
nmap('<leader>dQ', "<cmd>Trouble qflist toggle<cr>", 'Quickfix List')
