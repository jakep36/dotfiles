-- JSON configuration with support for .jsonld files
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure json parsers are installed
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "json", "json5" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          -- Add .jsonld files to jsonls
          filetypes = { "json", "jsonc", "jsonld" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      -- Treat .jsonld files like .json for formatting
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.jsonld = { "prettier" }

      -- Configure prettier to use json parser for .jsonld files
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = opts.formatters.prettier or {}

      -- Extend prettier args to specify json parser for .jsonld files
      local prettier_config = opts.formatters.prettier
      local original_args = prettier_config.args

      prettier_config.args = function(self, ctx)
        local args = original_args and original_args(self, ctx) or { "--stdin-filepath", "$FILENAME" }

        -- If the file is .jsonld, explicitly tell prettier to use json parser
        if ctx.filename and ctx.filename:match("%.jsonld$") then
          return vim.list_extend(vim.deepcopy(args), { "--parser", "json" })
        end

        return args
      end

      return opts
    end,
  },
}
