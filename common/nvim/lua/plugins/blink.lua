return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      -- add lazydev to your completion providers
      default = { "lazydev", "codecompanion" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100, -- show at a higher priority than lsp
        },
        codecompanion = {
          name = "CodeCompanion",
          module = "codecompanion.providers.completion.blink",
          enabled = true,
        },
      },
    },
  },
}
