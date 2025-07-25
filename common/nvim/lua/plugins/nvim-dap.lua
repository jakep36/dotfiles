return {
  "mfussenegger/nvim-dap",
  recommended = true,
  desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

  dependencies = {
    "rcarriga/nvim-dap-ui",
    -- virtual text for the debugger
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
  },

  opts = function()
    local dap = require("dap")

    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = { "/Users/jparsell/bin/dap/src/dapDebugServer.js", "${port}" },
      },
    }

    for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      dap.configurations[lang] = {
        {
          name = "Next.js: debug server-side",
          type = "pwa-node",
          request = "attach",
          port = 9230,
          skipFiles = { "<node_internals>/**", "node_modules/**" },
          cwd = "${workspaceFolder}",
        },
      }
    end
  end,
}
