return {
  -- Core Clojure plugins
  {
    "Olical/conjure",
    lazy = false, -- Load immediately for REPL integration
    ft = { "clojure" },
    config = function()
      -- Configure Conjure for deps.edn projects
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = true
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#cmd"] = "clojure -M:dev:test -m nrepl.cmdline"
      vim.g["conjure#client#clojure#nrepl#eval#auto_require"] = true
      vim.g["conjure#log#hud#width"] = 0.4
      vim.g["conjure#log#hud#height"] = 0.5
    end,
  },

  -- Structured editing for S-expressions
  {
    "guns/vim-sexp",
    ft = { "clojure", "scheme", "lisp" },
  },

  -- More intuitive key mappings for vim-sexp
  {
    "tpope/vim-sexp-mappings-for-regular-people",
    dependencies = { "guns/vim-sexp" },
    ft = { "clojure", "scheme", "lisp" },
  },
}
