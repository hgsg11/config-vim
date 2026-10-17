return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>e", false },
      { "<leader>E", false },
    },
    opts = {
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      -- Show <C-/> terminals as a centered popup instead of a bottom split.
      terminal = {
        win = {
          position = "float",
          border = "rounded",
          width = 0.8,
          height = 0.8,
          title = " Terminal ",
          title_pos = "center",
          keys = {
            term_jj = {
              "jj",
              function()
                vim.cmd("stopinsert")
              end,
              mode = "t",
              desc = "jj to normal mode",
            },
          },
          wo = {
            winhighlight = "Normal:SnacksTerminalNormal,NormalNC:SnacksTerminalNormal,FloatBorder:SnacksTerminalBorder,FloatTitle:SnacksTerminalTitle",
          },
        },
      },
      -- lazygit reuses Snacks.terminal, so it inherits terminal.win.keys; keep jj literal here.
      lazygit = {
        win = {
          keys = {
            term_jj = false,
          },
        },
      },
      picker = {
        enabled = true,
        sources = {
          files = {
            hidden = true,
            ignore = true,
          },
        },
      },
    },
  },
}
