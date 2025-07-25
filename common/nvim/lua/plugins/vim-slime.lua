return {
  -- slime (REPL integration)
  {
    "jpalardy/vim-slime",
    config = function()
      vim.g.slime_target = "tmux"
      vim.g.slime_bracketed_paste = 1
      vim.g.slime_default_config = {
        -- Lua doesn't have a string split function!
        socket_name = vim.api.nvim_eval('get(split($TMUX, ","), 0)'),
        target_pane = "{last}",
      }
      vim.g.slime_dont_ask_default = 1
    end,
  },
}
