require("nvchad.configs.lspconfig").defaults()

-- TypeScript language server powers diagnostics, completion, definitions,
-- references, and rename in JavaScript, TypeScript, and React files.
local servers = { "biome", "cssls", "html", "jsonls", "tailwindcss", "ts_ls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
