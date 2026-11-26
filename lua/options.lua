require "nvchad.options"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.sidescroll = 1 -- geser tampilan per kolom, lebih halus
vim.opt.sidescrolloff = 5 -- sisakan 5 kolom di kiri/kanan kursor
vim.opt.inccommand = "split"
vim.opt.autoread = true

-- Pengaturan tambahan untuk perbandingan diff.
vim.opt.diffopt:append "horizontal"

-- Lipatan dibuat dari struktur Tree-sitter dan dibiarkan terbuka saat file dimuat.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
