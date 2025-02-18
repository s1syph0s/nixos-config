require("persistence").setup()

-- load the session for the current directory
vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end,
  { desc = "Session: Load Current Directory" })
-- select a session to load
vim.keymap.set("n", "<leader>qS", function() require("persistence").select() end, { desc = "Session: Select" })
-- load the last session
vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end,
  { desc = "Session: Load Last Session" })
