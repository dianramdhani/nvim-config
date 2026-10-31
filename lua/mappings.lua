require "nvchad.mappings"

-- Keymap umum yang saya tambahkan.
local map = vim.keymap.set

map("n", "<leader>th", "<cmd>Telescope themes<CR>", { desc = "Buka pemilih tema" })
map("n", "<leader>tt", "<cmd>term<CR>", { desc = "Buka terminal di window aktif" })
map("n", "<leader>sv", "<cmd>split | wincmd L<CR>", { desc = "Bagi window ke kanan" })
map("n", "<leader>wm", function()
	if vim.t.nvim_window_focus_zoomed then
		vim.cmd("wincmd =")
	else
		vim.cmd("wincmd |")
		vim.cmd("wincmd _")
	end

	vim.t.nvim_window_focus_zoomed = not vim.t.nvim_window_focus_zoomed
end, { desc = "Besarkan/pulihkan ukuran window" })
map("n", ";", ":", { desc = "Buka command line" })
map("i", "jk", "<Esc>", { desc = "Kembali ke Normal mode" })

-- Fitur yang punya beberapa keymap dikelompokkan di file terpisah.
require "mappings.git"
require "mappings.workflow"
