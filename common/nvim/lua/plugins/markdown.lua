-- Markdown configuration overrides
return {
  -- Disable markdown linting/diagnostics
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = {}, -- Disable markdownlint
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        marksman = {
          -- Disable marksman LSP diagnostics for markdown
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
        },
      },
    },
  },
  -- Configure markdown-preview.nvim styling
  {
    "iamcco/markdown-preview.nvim",
    optional = true,
    opts = function()
      -- Set preview theme and styling options
      vim.g.mkdp_theme = "dark" -- Options: 'dark' or 'light'

      -- Customize CSS if you want (optional)
      -- vim.g.mkdp_markdown_css = '/path/to/your/markdown.css'
      -- vim.g.mkdp_highlight_css = '/path/to/your/highlight.css'

      -- Preview options
      vim.g.mkdp_auto_close = 0 -- Don't auto-close preview when changing buffers
      vim.g.mkdp_refresh_slow = 0 -- Auto refresh (0 = fast, 1 = slow on save)
      vim.g.mkdp_browser = "" -- Use default browser

      -- Available themes for syntax highlighting in preview
      -- vim.g.mkdp_highlight_css = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/github-dark.min.css'
    end,
  },
  -- You can also customize render-markdown.nvim (in-editor rendering)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {}, -- Set to {} to disable heading icons, or customize
      },
      checkbox = {
        enabled = true, -- Enable checkboxes
      },
    },
  },
}
