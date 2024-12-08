require("trouble").setup()


local nmap = function(keys, func, desc)
  if desc then
    desc = 'DAP: ' .. desc
  end

  vim.keymap.set('n', keys, func, { desc = desc })
end

nmap('<leader>dx', "<cmd>Trouble diagnostics toggle<cr>", 'Diagnostics (Trouble)')
nmap('<leader>dX', "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", 'Buffer Diagnostics (Trouble)')
nmap('<leader>cs', "<cmd>Trouble symbols toggle focus=false<cr>", 'Symbols (Trouble)')
nmap('<leader>cl', "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
  'LSP Definitions / references / ... (Trouble)')
nmap('<leader>dL', "<cmd>Trouble loclist toggle<cr>", 'Location List (Trouble)')
nmap('<leader>dQ', "<cmd>Trouble qflist toggle<cr>", 'Quickfix List (Trouble)')
