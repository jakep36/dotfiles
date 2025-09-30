return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  lazy = false,
  opts = function()
    local config = {
      terminal_cmd = "claude", -- Launch Claude Code directly
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
    -- Claude Code terminal
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model" },

    -- Send to Claude
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd<cr>", desc = "Add buffer to Claude" },

    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
