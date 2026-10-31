require "nvchad.options"

-- Pengaturan tambahan untuk perbandingan diff.
vim.opt.diffopt:append "horizontal"

-- Lipatan dibuat dari struktur Tree-sitter dan dibiarkan terbuka saat file dimuat.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
