require('zellij-nav').setup()
local map = vim.keymap.set
map("n", "<c-h>", "<cmd>ZellijNavigateLeftTab<cr>", { desc = "navigate left or tab" })
map("n", "<c-j>", "<cmd>ZellijNavigateDown<cr>", { desc = "navigate down" })
map("n", "<c-k>", "<cmd>ZellijNavigateUp<cr>", { desc = "navigate up" })
map("n", "<c-l>", "<cmd>ZellijNavigateRightTab<cr>", { desc = "navigate right or tab" })
