local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    javascript = { "biome" },
    typescript = { "biome" },
    javascriptreact = { "biome" },
    typescriptreact = { "biome" },
    css = { "biome" },
    html = { "prettier" },
    json = { "biome" },
    jsonc = { "biome" },
    yaml = { "prettier" },
    markdown = { "prettier" },
  },

  format_on_save = {
    -- Batas waktu dan aturan fallback saat menyimpan file.
    timeout_ms = 500,
    lsp_format = "fallback",
  },
}

return options
