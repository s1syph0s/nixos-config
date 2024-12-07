local db = require("dashboard")

db.setup({
  theme = 'doom',
  config = {
    week_header = {
      enable = true,
    },
    center = {
      {
        desc = 'Find sessions',
        key = 's',
        key_format = '%s', -- remove default surrounding `[]`
        action = 'lua require("persistence").select()'
      },
    },
    footer = {} --your footer
  }
})
