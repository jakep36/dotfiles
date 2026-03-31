vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local o = vim.opt

-- General
o.autowrite = true
o.clipboard = "unnamedplus"
o.confirm = true
o.mouse = "a"
o.number = true
o.relativenumber = false
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.showmode = false

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "nosplit"
o.grepformat = "%f:%l:%c:%m"
o.grepprg = "rg --vimgrep"

-- Indentation
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = false
o.smartindent = true
o.shiftround = true
o.breakindent = true

-- Display
o.wrap = false
o.spell = false
o.list = true
o.listchars = { tab = "▸ ", trail = "·" }
o.scrolloff = 4
o.sidescrolloff = 8
o.smoothscroll = true
o.laststatus = 3
o.pumblend = 10
o.pumheight = 10
o.conceallevel = 2
o.ruler = false
o.linebreak = true

-- Splits
o.splitbelow = true
o.splitright = true
o.splitkeep = "screen"

-- Files
o.backup = false
o.undofile = true
o.undolevels = 10000
o.updatetime = 200
o.isfname:append("@-@")

-- Folding (treesitter)
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldmethod = "expr"
o.foldtext = ""
o.foldlevel = 99

-- Completion
o.completeopt = "menu,menuone,noselect"

-- Misc
o.shortmess:append({ W = true, I = true, c = true, C = true })
o.timeoutlen = 300
o.wildmode = "longest:full,full"
o.winminwidth = 5
o.virtualedit = "block"
o.jumpoptions = "view"
o.formatoptions = "jcroqlnt"
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
o.fillchars = {
  foldopen = "-",
  foldclose = "+",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Diagnostics
vim.diagnostic.config({
  virtual_lines = true,
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.g.markdown_recommended_style = 0

-- Disable built-in plugins we don't need
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_tutor = 1
vim.g.loaded_zipPlugin = 1
