-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Delete default LazyVim keymaps
-- vim.keymap.del({ "n" }, "<C-j>")
-- vim.keymap.del({ "n" }, "<C-k>")
-- vim.keymap.del({ "n" }, "<C-h>")
-- vim.keymap.del({ "n" }, "<C-l>")

-- CodeCompanion mappings - disabled in favor of claudecode.nvim
-- map({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
-- map({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
-- map({ "n", "v" }, "<Leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
-- map({ "n", "v" }, "<Leader>aa", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
-- map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- vim tmux runner mappings
map({ "n", "v" }, "<leader>or", "<cmd>SlimeConfig<cr>")
map({ "n", "v" }, "<leader>ol", ":SlimeSend<cr>")

map({ "v" }, "<leader>foo", "<Cmd>lua print(vim.inspect(getVisualSelection()))<Cr>")
-- Expand 'cc' into 'CodeCompanion' in the command line - disabled
-- vim.cmd([[cab cc CodeCompanion]])

-- Add a special mapping for snacks explorer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_list",
  callback = function()
    -- Direct tmux navigation for left
    vim.keymap.set("n", "<C-h>", function()
      vim.fn.system("tmux select-pane -L")
    end, { buffer = true, silent = true, noremap = true })
  end,
})
