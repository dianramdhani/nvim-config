require("nvchad.configs.lspconfig").defaults()

-- Server bahasa yang dipakai untuk diagnostik, autocomplete, dan navigasi kode.
local servers = { "biome", "cssls", "html", "jsonls", "tailwindcss", "ts_ls" }
vim.lsp.enable(servers)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Cari referensi simbol" }))
    vim.keymap.set(
      "n",
      "<leader>ca",
      vim.lsp.buf.code_action,
      vim.tbl_extend("force", opts, { desc = "Tampilkan Code Action" })
    )
    vim.keymap.set(
      "n",
      "<leader>ld",
      vim.diagnostic.open_float,
      vim.tbl_extend("force", opts, { desc = "Lihat diagnostic baris ini" })
    )
  end,
})

-- Lihat :help vim.lsp.config untuk mengubah pengaturan server bahasa.
