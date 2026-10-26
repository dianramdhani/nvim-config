require("nvchad.configs.lspconfig").defaults()

-- TypeScript language server powers diagnostics, completion, definitions,
-- references, and rename in JavaScript, TypeScript, and React files.
local servers = { "biome", "cssls", "html", "jsonls", "tailwindcss", "ts_ls" }
vim.lsp.enable(servers)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "LSP references" }))
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP code action" }))
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))
  end,
})

-- read :h vim.lsp.config for changing options of lsp servers 
