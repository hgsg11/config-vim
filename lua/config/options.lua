-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 常にシステムのクリップボードと共有する（LazyVim は SSH 中だけ "" にする）
vim.opt.clipboard = "unnamedplus"

-- SSH 越しだと pbcopy はリモート側の Mac のクリップボードに入ってしまうので、
-- OSC 52 で手元の端末へ送る（tmux は set-clipboard on で中継する）。
-- OSC 52 の読み取りは非対応の端末が多く固まるので、貼り付けは最後にコピーした内容を返す。
-- 手元で別アプリからコピーしたものは Cmd+V で貼る。
if vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  local cache = { ["+"] = { { "" }, "v" }, ["*"] = { { "" }, "v" } }
  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      cache[reg] = { lines, regtype }
      send(lines, regtype)
    end
  end
  local function paste(reg)
    return function()
      return cache[reg]
    end
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
  }
end
