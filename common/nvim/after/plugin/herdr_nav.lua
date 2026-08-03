-- Seamless <C-h/j/k/l> across herdr panes and nvim splits.
-- Loads the editor shim from the vim-herdr-navigation herdr plugin (installed
-- via `herdr plugin install paulbkim-dev/vim-herdr-navigation`). The shim falls
-- back to vim-tmux-navigator behavior under $TMUX and plain wincmd elsewhere,
-- so this is a no-op cost on machines without herdr.
local shims = vim.fn.glob(
  vim.fn.expand("~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua"),
  false,
  true
)
if #shims > 0 then
  dofile(shims[1])
end
