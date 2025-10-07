-- Override gitui extra to prevent deletion of git log keymaps
return {
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = { ensure_installed = { "gitui" } },
    keys = {
      {
        "<leader>gG",
        function()
          Snacks.terminal({ "gitui" })
        end,
        desc = "GitUi (cwd)",
      },
      {
        "<leader>gg",
        function()
          Snacks.terminal({ "gitui" }, { cwd = LazyVim.root.get() })
        end,
        desc = "GitUi (Root Dir)",
      },
    },
    -- Remove the init function that deletes keymaps
    init = function()
      -- Don't delete the git log keymaps - we want to keep them
    end,
  },
  -- Explicitly set the git keymaps we want
  {
    "folke/snacks.nvim",
    optional = true,
    keys = {
      {
        "<leader>gf",
        function()
          Snacks.picker.git_log_file()
        end,
        desc = "Git Current File History",
      },
      {
        "<leader>gl",
        function()
          Snacks.picker.git_log({ cwd = LazyVim.root.git() })
        end,
        desc = "Git Log",
      },
    },
  },
}
