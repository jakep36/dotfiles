-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

opt.termguicolors = true
opt.backup = false -- Disable creation of backup files
opt.breakindent = true -- Maintain indent when wrapping indented lines
-- opt.clipboard = "unnamedplus" -- Use system clipboard
opt.isfname:append("@-@") -- Allow '@' and '-' as part of a word in file names
opt.list = true -- Enable display of special characters
opt.listchars = { tab = "▸ ", trail = "·" } -- Set characters for tabs and trailing spaces
opt.mouse = "a" -- Enable mouse for all modes
opt.number = true -- Show line numbers
opt.smartcase = true -- Use case-sensitive search if there is a capital letter in the pattern
opt.wrap = false -- Disable line wrapping
opt.spell = false -- Disable spell checking
opt.tabstop = 2
opt.expandtab = false
opt.relativenumber = false
if vim.fn.has("nvim-0.11") == 1 then
  opt.smoothscroll = true
  opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  opt.foldmethod = "expr"
  opt.foldtext = ""
  -- opt.foldtext = "v:lua.vim.treesitter.foldtext()"
  vim.diagnostic.config({
    virtual_text = { virtual_lines = true },
  })
else
  opt.foldmethod = "indent"
  opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
end
