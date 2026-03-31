-- Colorscheme (load first)
vim.cmd.colorscheme("tokyonight-night")

-- Catppuccin (available but not active)
require("catppuccin").setup({
  custom_highlights = function(colors)
    return {
      Comment = { bg = colors.base, fg = colors.blue },
      SpecialKey = { bg = colors.none },
      TabLineSel = { bg = colors.pink },
      CmpBorder = { fg = colors.surface2 },
      Pmenu = { bg = colors.none },
      Conditional = { bg = colors.base, fg = colors.lavender },
    }
  end,
})

-- Mini plugins
require("mini.icons").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.ai").setup()

-- Status line
require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
  },
})

-- Which-key
require("which-key").setup({
  spec = {
    { "<leader>a", group = "ai" },
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "file/find" },
    { "<leader>g", group = "git" },
    { "<leader>q", group = "session" },
    { "<leader>r", group = "refactor" },
    { "<leader>s", group = "search" },
    { "<leader>u", group = "ui/toggle" },
    { "<leader>w", group = "window" },
    { "<leader>x", group = "diagnostics" },
  },
})

-- Snacks
require("snacks").setup({
  bigfile = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  picker = {
    sources = {
      explorer = {
        hidden = true,
        ignored = true,
      },
      gh_issue = { state = "open" },
      gh_pr = { state = "open" },
    },
  },
})

-- Debug utilities (available after snacks loads)
_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
vim.print = _G.dd

-- Trouble
require("trouble").setup({ use_diagnostic_signs = true })

-- Todo comments
require("todo-comments").setup()

-- Persistence (sessions)
require("persistence").setup({
  dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
  options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
  save_empty = false,
})

-- fzf-lua
require("fzf-lua").setup()

-- Grug-far (search & replace)
require("grug-far").setup()

-- Treesitter
-- In Neovim 0.12, highlight and indent are built-in (vim.treesitter).
-- nvim-treesitter now only manages parser installation.
-- Install parsers with :TSInstall <lang> or run this on first launch:
--   :TSInstall bash html javascript json json5 lua markdown markdown_inline python query regex rust toml tsx typescript vim vimdoc yaml
require("nvim-treesitter.config").setup()

-- Autotag (HTML/JSX)
require("nvim-ts-autotag").setup()

-- Ts-comments
require("ts-comments").setup()

-- Refactoring
require("refactoring").setup({
  prompt_func_return_type = {
    go = false,
    java = false,
    cpp = false,
    c = false,
    h = false,
    hpp = false,
    cxx = false,
  },
  prompt_func_param_type = {
    go = false,
    java = false,
    cpp = false,
    c = false,
    h = false,
    hpp = false,
    cxx = false,
  },
  printf_statements = {},
  print_var_statements = {},
  show_success_message = true,
})

-- Completion (blink.cmp)
require("blink.cmp").setup({
  sources = {
    default = { "lsp", "path", "snippets", "buffer", "lazydev" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
  keymap = { preset = "default" },
})

-- Formatting
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonld = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    markdown = { "prettier" },
    lua = { "stylua" },
    python = { "ruff_format" },
    rust = { "rustfmt" },
  },
  format_on_save = {
    timeout_ms = 3000,
    lsp_format = "fallback",
  },
})

-- Linting (nvim-lint has no setup(), just configure and use try_lint)
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- Git signs
require("gitsigns").setup()

-- Crates (Rust)
require("crates").setup()

-- Lazydev (Lua/Neovim development)
require("lazydev").setup()

-- Claude Code
local claude_config = {
  terminal_cmd = "claude",
  diff_opts = {
    layout = "vertical",
    open_in_new_tab = true,
    auto_close_on_accept = true,
    keep_terminal_focus = false,
  },
}

if vim.fn.exists("$TMUX") == 1 then
  local tmux_provider = require("tmux_provider")
  claude_config.terminal = {
    provider = tmux_provider,
    split_side = "right",
    split_width_percentage = 0.4,
  }
else
  claude_config.terminal = { provider = "native" }
end

require("claudecode").setup(claude_config)

-- VS Code diff
require("codediff").setup({
  keymaps = {
    view = {
      quit = "q",
      toggle_explorer = "<leader>b",
      next_hunk = "]c",
      prev_hunk = "[c",
      next_file = "]f",
      prev_file = "[f",
    },
    explorer = {
      select = "<CR>",
      hover = "K",
      refresh = "R",
    },
  },
})

-- Smooth scrolling
require("neoscroll").setup({ duration_multiplier = 0.3 })

-- Git permalinks
require("gitlinker").setup()

-- Treesitter context (sticky scope header)
require("treesitter-context").setup({
  max_lines = 3,
})

-- Better quickfix
require("bqf").setup()

-- Undotree (no setup needed, just commands)
