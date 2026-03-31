-- Mason (tool installer)
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls",
    "pyright",
    "jsonls",
    "lua_ls",
  },
})

-- Enable LSP servers (configs live in lsp/*.lua)
vim.lsp.enable({
  "ts_ls",
  "pyright",
  "jsonls",
  "lua_ls",
  -- rust-analyzer is handled by rustaceanvim
})

-- Keymaps and completion on LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local buf = ev.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gI", vim.lsp.buf.implementation, "Go to Implementation")
    map("n", "gy", vim.lsp.buf.type_definition, "Type Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
  end,
})
