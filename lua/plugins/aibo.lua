-- AI companion (claude / codex) running in a side terminal with a floating prompt.
-- https://github.com/lambdalisue/nvim-aibo

-- Open the console as a right-hand split that takes half of the screen.
local function opener()
  local width = math.floor(vim.o.columns / 2)
  return string.format('-opener="botright %dvsplit"', width)
end

local function aibo(flags, cmd)
  return function()
    vim.cmd(string.format("Aibo %s %s %s", opener(), flags, cmd))
  end
end

-- Move to the neighbouring window. From the floating prompt, hop back to its
-- console first (the prompt auto-closes on WinLeave, its text is kept).
local function navigate(dir)
  return function()
    local float = vim.api.nvim_win_get_config(0)
    if float.relative ~= "" and float.win and vim.api.nvim_win_is_valid(float.win) then
      vim.api.nvim_set_current_win(float.win)
    end
    vim.cmd.wincmd(dir)
  end
end

local function set_nav_keys(bufnr)
  local opts = { buffer = bufnr, nowait = true, silent = true }
  for _, dir in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set("n", "<C-" .. dir .. ">", navigate(dir), vim.tbl_extend("force", opts, { desc = "Go to window " .. dir }))
  end
  -- <C-l> is taken by navigation; keep "clear terminal" reachable.
  vim.keymap.set("n", "g<C-l>", "<Plug>(aibo-send)<C-l>", opts)
  -- Global <C-w> deletes the buffer (keymaps.lua), which would kill the agent.
  -- Restore Vim's native window prefix (<C-w>h, <C-w>=, ...) in aibo buffers.
  vim.keymap.set("n", "<C-w>", "<C-w>", { buffer = bufnr, noremap = true })
end

local function disable_decorations(bufnr)
  vim.b[bufnr].miniindentscope_disable = true
  vim.b[bufnr].minitrailspace_disable = true
  vim.b[bufnr].minicursorword_disable = true
end

local function style_console_window(winid)
  vim.wo[winid].cursorline = false
  vim.wo[winid].foldcolumn = "0"
  vim.wo[winid].statuscolumn = ""
  vim.wo[winid].winhighlight = "Normal:AiboConsoleNormal,NormalNC:AiboConsoleNormal"
end

return {
  {
    "lambdalisue/nvim-aibo",
    cmd = { "Aibo", "AiboSend" },
    keys = {
      { "<leader>aa", aibo("-toggle", "claude"), desc = "Toggle Claude" },
      { "<leader>af", aibo("-focus", "claude"), desc = "Focus Claude" },
      { "<leader>ac", aibo("", "claude --continue"), desc = "Claude (continue)" },
      { "<leader>ar", aibo("", "claude --resume"), desc = "Claude (resume)" },
      { "<leader>ax", aibo("-toggle", "codex"), desc = "Toggle Codex" },
      { "<leader>as", "<Cmd>AiboSend -input<CR>", desc = "Send buffer to prompt" },
      { "<leader>as", ":AiboSend -input<CR>", mode = "x", desc = "Send selection to prompt" },
      { "<leader>aS", ":AiboSend -submit<CR>", mode = "x", desc = "Send selection and submit" },
    },
    opts = {
      prompt_height = 8,
      prompt_blend_insert = 0,
      prompt_blend_normal = 15,
      prompt = {
        on_attach = function(bufnr)
          set_nav_keys(bufnr)
          disable_decorations(bufnr)
          -- Close the prompt with `q` in Normal mode, same as the default <Esc>.
          vim.keymap.set("n", "q", "<Cmd>q<CR>", { buffer = bufnr, nowait = true, silent = true, desc = "Close prompt" })
          -- The prompt opens in Insert mode, so allow jumping out from there too.
          for _, dir in ipairs({ "h", "l" }) do
            vim.keymap.set("i", "<C-" .. dir .. ">", function()
              vim.cmd.stopinsert()
              navigate(dir)()
            end, { buffer = bufnr, nowait = true, silent = true, desc = "Go to window " .. dir })
          end
        end,
      },
      console = {
        on_attach = function(bufnr)
          set_nav_keys(bufnr)
          disable_decorations(bufnr)
          for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
            style_console_window(winid)
          end
          -- Re-apply when the console is toggled back into a new window.
          vim.api.nvim_create_autocmd("BufWinEnter", {
            buffer = bufnr,
            callback = function()
              style_console_window(vim.api.nvim_get_current_win())
            end,
          })
        end,
      },
    },
  },
}
