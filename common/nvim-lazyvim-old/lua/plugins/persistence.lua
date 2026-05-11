-- Session management for Neovim
-- Automatically saves and restores sessions
-- Works with tmux-resurrect for complete workspace restoration
return {
  -- Persistence.nvim - LazyVim's default session manager
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"), -- directory where session files are saved
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
      pre_save = nil, -- function to run before saving
      save_empty = false, -- don't save if there are no open file buffers
    },
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- Alternative: Auto-session (more feature-rich, works well with tmux-resurrect)
  -- Uncomment below to use auto-session instead of persistence.nvim
  -- {
  --   "rmagatti/auto-session",
  --   lazy = false,
  --   opts = {
  --     log_level = "error",
  --     auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
  --     auto_session_use_git_branch = false,
  --     auto_session_enable_last_session = false,
  --     auto_save_enabled = true,
  --     auto_restore_enabled = true,
  --   },
  -- },
}