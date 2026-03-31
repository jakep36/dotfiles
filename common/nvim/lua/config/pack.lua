-- Plugin Management (vim.pack — built into Neovim 0.12+)
-- ===========================================================================
--
-- HOW TO ADD A NEW PLUGIN:
--
--   1. Add its GitHub URL as a string to the vim.pack.add() list below.
--      Example: "https://github.com/author/plugin-name.nvim",
--
--   2. If the plugin needs configuration, add a require/setup call in
--      lua/config/plugins.lua:
--        require("plugin-name").setup({ ... })
--
--   3. If the plugin needs keymaps, add them in lua/config/keymaps.lua.
--
--   4. If the plugin needs a post-install build step (e.g. compiling or
--      downloading), add a condition to the PackChanged autocmd below.
--
--   5. Restart nvim. Plugins are installed automatically on first launch.
--      To update all plugins:  :call vim.pack.update()
--      To remove a plugin:     delete its URL below, restart, then
--                               :call vim.pack.del({"plugin-name"})
--
-- HOW TO ADD A NEW LSP SERVER:
--
--   1. Create a file at lsp/<server_name>.lua returning a config table:
--        return {
--          filetypes = { "lang" },
--          root_markers = { ".git" },
--          settings = { ... },       -- optional
--        }
--
--   2. Add the server name to vim.lsp.enable() in lua/config/lsp.lua.
--
--   3. Add the server name to mason-lspconfig ensure_installed in
--      lua/config/lsp.lua so it gets auto-installed.
--
-- HOW TO ADD A NEW FORMATTER OR LINTER:
--
--   Formatters: add to conform.nvim's formatters_by_ft table in plugins.lua.
--   Linters:    add to nvim-lint config in plugins.lua.
--   Install:    add the tool name to mason ensure_installed in lsp.lua,
--               or install it manually (brew, npm, pip, etc.).
--
-- ===========================================================================

-- Build hooks for plugins that need post-install steps
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    elseif name == "blink.cmp" and (kind == "install" or kind == "update") then
      vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path })
    end
  end,
})

vim.pack.add({
  -------------------------------------------------------
  -- UI & Theme
  -------------------------------------------------------

  -- tokyonight.nvim: Dark colorscheme with multiple styles (night, storm, moon, day).
  -- Currently active via `colorscheme tokyonight-night` in plugins.lua.
  -- Drop if: you switch to catppuccin or another scheme full-time.
  "https://github.com/folke/tokyonight.nvim",

  -- catppuccin: Warm pastel colorscheme with four flavors (latte, frappe, macchiato, mocha).
  -- Configured but not active. Switch with `:colorscheme catppuccin`.
  -- Drop if: you never use it. Keeping both costs nothing at runtime.
  "https://github.com/catppuccin/nvim",

  -- lualine.nvim: Status line at the bottom showing mode, file, git branch, diagnostics, etc.
  -- Drop if: you're fine with no status line or the built-in ruler (`set laststatus=0`).
  "https://github.com/nvim-lualine/lualine.nvim",

  -- mini.icons: Provides file-type icons used by lualine, fzf-lua, snacks picker, trouble, etc.
  -- Drop if: you remove all plugins that render icons (most modern plugins expect this).
  "https://github.com/echasnovski/mini.icons",

  -------------------------------------------------------
  -- Editor
  -------------------------------------------------------

  -- which-key.nvim: Popup that shows available keymaps after pressing a leader key.
  -- Essential for discovering shortcuts you've forgotten.
  -- Drop if: you have all your keymaps memorized.
  "https://github.com/folke/which-key.nvim",

  -- snacks.nvim: Swiss-army-knife plugin providing: file picker, grep, git log/blame/browse,
  -- GitHub issues/PRs, floating terminal, notification system, buffer delete, word references,
  -- bigfile handling, status column, and debug utilities. Heavily used throughout keymaps.
  -- Drop if: you replace its individual features with standalone plugins (fzf-lua for search,
  -- gitsigns for blame, etc.). Would require rewriting many keymaps.
  "https://github.com/folke/snacks.nvim",

  -- trouble.nvim: Pretty list for diagnostics, references, quickfix, and location lists.
  -- Shows all warnings/errors across the project in a navigable split.
  -- Drop if: you're fine using the built-in quickfix (`:copen`) and location list.
  "https://github.com/folke/trouble.nvim",

  -- todo-comments.nvim: Highlights TODO, FIXME, HACK, NOTE comments in source code
  -- and lets you search/list them with `:TodoTrouble` or `:TodoFzfLua`.
  -- Drop if: you don't use TODO comments or don't need them highlighted.
  "https://github.com/folke/todo-comments.nvim",

  -- persistence.nvim: Automatically saves and restores editor sessions (open buffers,
  -- window layout, cursor positions) per working directory.
  -- Keymaps: <leader>qs (restore), <leader>ql (last session), <leader>qd (stop saving).
  -- Drop if: you always start nvim fresh and don't need session restore.
  "https://github.com/folke/persistence.nvim",

  -- fzf-lua: Fuzzy finder powered by fzf for files, grep, buffers, git, LSP symbols, etc.
  -- Alternative/complement to snacks.picker. Some commands may overlap.
  -- Drop if: snacks.picker covers all your search needs.
  "https://github.com/ibhagwan/fzf-lua",

  -- grug-far.nvim: Project-wide find-and-replace UI with live preview of changes.
  -- Opens a split where you type a search pattern and replacement, then apply.
  -- Drop if: you prefer using sed/rg from the terminal or snacks.picker grep.
  "https://github.com/MagicDuck/grug-far.nvim",

  -- undotree: Visual undo history browser. Neovim undo is branching (not linear),
  -- so you can lose states by undoing past a fork. This shows every branch and lets
  -- you jump to any past state. Toggle with <leader>cu.
  -- Drop if: you never need to recover lost undo branches.
  "https://github.com/mbbill/undotree",

  -- nvim-bqf: Better quickfix window with preview pane, fuzzy filtering, and signs.
  -- Enhances the quickfix list used by grep results, LSP references, diagnostics, etc.
  -- Drop if: you rarely use the quickfix list or the default is enough.
  "https://github.com/kevinhwang91/nvim-bqf",

  -------------------------------------------------------
  -- Treesitter
  -------------------------------------------------------

  -- nvim-treesitter: Parses source code into syntax trees for accurate highlighting,
  -- folding, indentation, and textobjects. Foundation for many other plugins.
  -- Drop if: never. This is core infrastructure.
  "https://github.com/nvim-treesitter/nvim-treesitter",

  -- nvim-treesitter-textobjects: Adds treesitter-aware text objects like "select function"
  -- (vaf), "select class" (vac), "move to next function" (]m), etc.
  -- Drop if: you don't use structural text objects beyond the basics (w, p, etc.).
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",

  -- nvim-ts-autotag: Automatically closes and renames HTML/JSX tags.
  -- Type `<div>` and it inserts `</div>`. Rename opening tag and closing tag updates.
  -- Drop if: you don't write HTML/JSX/TSX.
  "https://github.com/windwp/nvim-ts-autotag",

  -- nvim-treesitter-context: Shows the function/class/block scope at the top of the
  -- screen when you scroll deep into a long function. Toggle with <leader>ut.
  -- Drop if: you prefer no sticky context header.
  "https://github.com/nvim-treesitter/nvim-treesitter-context",

  -------------------------------------------------------
  -- Coding
  -------------------------------------------------------

  -- ts-comments.nvim: Treesitter-aware commenting. Knows the correct comment syntax
  -- for embedded languages (e.g., JS inside HTML, CSS inside JSX).
  -- Uses built-in gc/gcc motions. Drop if: you only edit single-language files.
  "https://github.com/folke/ts-comments.nvim",

  -- mini.pairs: Automatically inserts closing brackets, quotes, and parentheses.
  -- Type `(` and it inserts `)` with cursor between them.
  -- Drop if: auto-pairs annoy you or you prefer typing closing chars manually.
  "https://github.com/echasnovski/mini.pairs",

  -- mini.surround: Add, delete, or change surrounding characters (brackets, quotes, tags).
  -- `sa` to add, `sd` to delete, `sr` to replace surroundings.
  -- Drop if: you don't manipulate surrounding delimiters often.
  "https://github.com/echasnovski/mini.surround",

  -- mini.ai: Enhanced text objects for "around" and "inside" selections.
  -- Adds targets like function arguments (a), brackets (b), and custom patterns.
  -- Drop if: built-in text objects (iw, i(, i", etc.) are enough for you.
  "https://github.com/echasnovski/mini.ai",

  -- refactoring.nvim: Automated refactoring operations powered by treesitter.
  -- Extract function/variable, inline variable, debug print statements.
  -- Keymaps: <leader>r* family. Drop if: you refactor manually or via LSP rename only.
  "https://github.com/ThePrimeagen/refactoring.nvim",

  -- plenary.nvim: Lua utility library used as a dependency by refactoring.nvim and others.
  -- Provides async helpers, path utilities, test framework.
  -- Drop if: nothing depends on it (currently refactoring.nvim requires it).
  "https://github.com/nvim-lua/plenary.nvim",

  -- friendly-snippets: Collection of pre-made snippets for many languages.
  -- Provides snippets for JS/TS, Python, Rust, HTML, and more via blink.cmp.
  -- Drop if: you don't use snippet expansion or prefer writing your own.
  "https://github.com/rafamadriz/friendly-snippets",

  -- nvim-jqx: Interactive JSON/YAML browser. Run `:JqxList` to browse keys,
  -- `:JqxQuery` to run jq queries on the current buffer.
  -- Drop if: you use jq from the terminal or don't inspect large JSON files in nvim.
  "https://github.com/gennaro-tedesco/nvim-jqx",

  -------------------------------------------------------
  -- Completion
  -------------------------------------------------------

  -- blink.cmp: Fast completion engine with fuzzy matching, multiple sources
  -- (LSP, snippets, buffer, path), ghost text preview, and documentation popup.
  -- Drop if: you switch to native vim.lsp.completion.enable() (simpler, LSP-only,
  -- no fuzzy matching or multi-source support).
  "https://github.com/saghen/blink.cmp",

  -------------------------------------------------------
  -- LSP & Tools
  -------------------------------------------------------

  -- mason.nvim: Package manager for LSP servers, formatters, linters, and DAP adapters.
  -- Installs tools into a local directory so you don't need system-wide installs.
  -- Drop if: you install all dev tools via your OS package manager or npm/pip globally.
  "https://github.com/mason-org/mason.nvim",

  -- mason-lspconfig.nvim: Bridge between mason and LSP. Auto-installs servers listed
  -- in ensure_installed and maps mason package names to LSP server names.
  -- Drop if: you remove mason or manage server installation manually.
  "https://github.com/mason-org/mason-lspconfig.nvim",

  -- lazydev.nvim: Configures lua_ls to understand Neovim's Lua API, plugin types,
  -- and your config structure. Provides completions for vim.*, require(), etc.
  -- Drop if: you never edit Neovim Lua config files.
  "https://github.com/folke/lazydev.nvim",

  -- SchemaStore.nvim: Catalog of JSON/YAML schemas for common config files
  -- (package.json, tsconfig.json, GitHub Actions, etc.). Fed to jsonls for validation.
  -- Drop if: you don't need schema validation in JSON files.
  "https://github.com/b0o/SchemaStore.nvim",

  -------------------------------------------------------
  -- Formatting & Linting
  -------------------------------------------------------

  -- conform.nvim: Formatter manager. Runs prettier, stylua, rustfmt, ruff, etc.
  -- on save or on demand (<leader>cf). Configured per filetype in plugins.lua.
  -- Drop if: you rely entirely on LSP formatting or format from the terminal.
  "https://github.com/stevearc/conform.nvim",

  -- nvim-lint: Async linter that runs external linters (eslint, ruff, etc.) and
  -- reports results as native diagnostics. Complements LSP diagnostics.
  -- Drop if: your LSP servers handle all linting (eslint-lsp, ruff-lsp, etc.).
  "https://github.com/mfussenegger/nvim-lint",

  -------------------------------------------------------
  -- Git
  -------------------------------------------------------

  -- gitsigns.nvim: Shows git diff signs in the gutter (added/changed/deleted lines),
  -- inline blame, hunk staging/resetting, and hunk navigation ([c / ]c).
  -- Drop if: you only use git from the terminal and don't need in-editor git info.
  "https://github.com/lewis6991/gitsigns.nvim",

  -------------------------------------------------------
  -- Language-specific
  -------------------------------------------------------

  -- rustaceanvim: All-in-one Rust development plugin. Manages rust-analyzer LSP,
  -- provides cargo commands, debugging, inlay hints, and crate graph visualization.
  -- Replaces nvim-lspconfig for Rust. Drop if: you stop writing Rust.
  "https://github.com/mrcjkb/rustaceanvim",

  -- crates.nvim: Shows crate version info inline in Cargo.toml files.
  -- Displays latest version, lets you update versions, and shows dependency features.
  -- Drop if: you manage Cargo.toml versions from the terminal with cargo.
  "https://github.com/saecki/crates.nvim",

  -------------------------------------------------------
  -- Claude Code & Diffs
  -------------------------------------------------------

  -- claudecode.nvim: Integrates Claude Code CLI into Neovim. Opens Claude in a
  -- tmux pane (or native terminal), sends selections, and handles diff review.
  -- Keymaps: <leader>a* family. Drop if: you only use Claude Code from the terminal.
  "https://github.com/coder/claudecode.nvim",

  -- vscode-diff.nvim: VS Code-style side-by-side diff viewer with file explorer.
  -- Used for reviewing Claude Code diffs. Open with `:CodeDiff`.
  -- Drop if: you use a different diff tool or the built-in vimdiff.
  "https://github.com/esmuellert/vscode-diff.nvim",

  -- nui.nvim: UI component library (popups, splits, inputs). Required by vscode-diff.nvim.
  -- Drop if: nothing depends on it (currently vscode-diff requires it).
  "https://github.com/MunifTanjim/nui.nvim",

  -------------------------------------------------------
  -- Tmux
  -------------------------------------------------------

  -- vim-tmux-navigator: Seamless navigation between nvim splits and tmux panes
  -- using <C-h/j/k/l>. Without this, those keys only move between nvim windows.
  -- Drop if: you don't use tmux, or you navigate panes with tmux prefix keys instead.
  "https://github.com/christoomey/vim-tmux-navigator",

  -------------------------------------------------------
  -- Scrolling
  -------------------------------------------------------

  -- gitlinker.nvim: Copy GitHub/GitLab/Bitbucket permalink URLs for current line or selection.
  -- Use <leader>gy in normal or visual mode to copy a permalink to clipboard.
  -- Drop if: you use Snacks.gitbrowse (<leader>gY) instead.
  "https://github.com/linrongbin16/gitlinker.nvim",

  -- neoscroll.nvim: Smooth scrolling for <C-u>, <C-d>, <C-b>, <C-f>, zt, zz, zb.
  -- Animates scroll instead of jumping, making it easier to track cursor position.
  -- Drop if: you prefer instant jumps or find animation distracting.
  "https://github.com/karb94/neoscroll.nvim",
}, { load = true })
