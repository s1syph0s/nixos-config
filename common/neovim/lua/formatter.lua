require('conform').setup({
  format_on_save = function (bufnr)
    local disable_ft = { c = true, cpp = true }
    return {
      timeout_ms = 500,
      lsp_fallback = not disable_ft[vim.bo[bufnr].filetype],
    }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
  },
})
