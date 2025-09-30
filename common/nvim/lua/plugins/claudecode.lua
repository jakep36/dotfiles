return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  lazy = false,
  opts = function()
    local config = {
      terminal_cmd = vim.fn.expand("~/.claude/local/claude") .. " --ide", -- Add --ide flag for integration
      diff_opts = {
        layout = "vertical", -- Use vertical layout
        open_in_new_tab = true, -- Open in new tab to isolate from existing buffers
        auto_close_on_accept = true,
        keep_terminal_focus = false,
      },
    }

    -- Check if we're in tmux
    if vim.fn.exists("$TMUX") == 1 then
      -- Use the tmux provider based on PR #50
      local tmux_provider = require("tmux_provider")

      config.terminal = {
        provider = tmux_provider,
        split_side = "right", -- Position panes to the right
        split_width_percentage = 0.4, -- 40% of window width
      }
    else
      -- When not in tmux, use native provider (nvim terminal)
      config.terminal = {
        provider = "native",
      }
    end

    return config
  end,
  config = true,
  keys = {
    -- Your keymaps here
  },
}
