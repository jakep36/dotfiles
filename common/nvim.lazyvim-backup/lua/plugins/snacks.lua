return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Enable the GitHub integration
    gh = {
      -- Enable GitHub features
      enabled = true,
    },
    -- Configure the picker for GitHub features
    picker = {
      sources = {
        gh_issue = {
          -- Default to showing open issues
          state = "open",
        },
        gh_pr = {
          -- Default to showing open PRs
          state = "open",
        },
      },
    },
    -- Enable other useful Snacks features
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- Smart picker (leader + spacebar)
    {
      "<leader><space>",
      function() Snacks.picker.smart() end,
      desc = "Smart Picker"
    },

    -- GitHub Issues
    {
      "<leader>gi",
      function() Snacks.picker.gh_issue() end,
      desc = "GitHub Issues (open)"
    },
    {
      "<leader>gI",
      function() Snacks.picker.gh_issue({ state = "all" }) end,
      desc = "GitHub Issues (all)"
    },

    -- GitHub Pull Requests
    {
      "<leader>gp",
      function() Snacks.picker.gh_pr() end,
      desc = "GitHub Pull Requests (open)"
    },
    {
      "<leader>gP",
      function() Snacks.picker.gh_pr({ state = "all" }) end,
      desc = "GitHub Pull Requests (all)"
    },

    -- GitHub repository navigation
    {
      "<leader>gr",
      function() Snacks.picker.gh_repo() end,
      desc = "GitHub Repositories"
    },

    -- Additional useful Snacks keybindings
    {
      "<leader>un",
      function() Snacks.notifier.hide() end,
      desc = "Dismiss All Notifications"
    },
    {
      "<leader>bd",
      function() Snacks.bufdelete() end,
      desc = "Delete Buffer"
    },
    {
      "<leader>gg",
      function() Snacks.lazygit() end,
      desc = "Lazygit"
    },
    {
      "<leader>gb",
      function() Snacks.git.blame_line() end,
      desc = "Git Blame Line"
    },
    {
      "<leader>gB",
      function() Snacks.gitbrowse() end,
      desc = "Git Browse"
    },
    {
      "<leader>gf",
      function() Snacks.lazygit.log_file() end,
      desc = "Lazygit Current File History"
    },
    {
      "<leader>gl",
      function() Snacks.lazygit.log() end,
      desc = "Lazygit Log (cwd)"
    },
    {
      "<c-/>",
      function() Snacks.terminal() end,
      desc = "Toggle Terminal"
    },
    {
      "<c-_>",
      function() Snacks.terminal() end,
      desc = "which_key_ignore"
    },
    {
      "]]",
      function() Snacks.words.jump(vim.v.count1) end,
      desc = "Next Reference",
      mode = { "n", "t" }
    },
    {
      "[[",
      function() Snacks.words.jump(-vim.v.count1) end,
      desc = "Prev Reference",
      mode = { "n", "t" }
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for easier access
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override vim.print to use snacks for `:=` command
      end,
    })
  end,
}