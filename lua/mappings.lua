require "nvchad.mappings"

-- Keymap umum yang saya tambahkan.
local map = vim.keymap.set

map("n", "<leader>th", "<cmd>Telescope themes<CR>", { desc = "Buka pemilih tema" })
map("n", "<leader>ff", "<cmd>Telescope find_files hidden=true<CR>", { desc = "Cari file termasuk folder tersembunyi" })
map("n", "<leader>fr", "<cmd>Telescope resume<CR>", { desc = "Buka lagi pencarian Telescope terakhir" })
map("n", "<leader>ft", function()
	local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
	local telescope = require "telescope"
	telescope.load_extension "todo-comments"
	-- Tata letak sama dengan <leader>gt: daftar kecil di atas, pratinjau besar di bawah.
	telescope.extensions["todo-comments"].todo {
		layout_strategy = "vertical",
		layout_config = {
			width = 0.95,
			height = 0.95,
			prompt_position = "top",
			mirror = true,
			preview_cutoff = 0,
			preview_height = 0.67,
		},
		attach_mappings = function(_, map_picker)
			-- Menyalin "path#Lbaris" (format sama dengan <leader>cp), lalu menutup daftar.
			local copy_todo = function(prompt_bufnr)
				local entry = require("telescope.actions.state").get_selected_entry()
				if not entry then
					return
				end
				local file = vim.fs.relpath(root, vim.fn.fnamemodify(entry.filename, ":p")) or entry.filename
				local text = string.format("%s#L%d", file, entry.lnum)
				vim.fn.setreg("+", text)
				vim.fn.setreg('"', text)
				vim.notify("Disalin: " .. file .. "#L" .. entry.lnum, vim.log.levels.INFO)
				require("telescope.actions").close(prompt_bufnr)
			end
			-- Ctrl-y bekerja langsung saat mengetik; <leader>cp hanya di Normal mode (setelah Esc).
			map_picker({ "i", "n" }, "<C-y>", copy_todo)
			map_picker("n", "<leader>cp", copy_todo)
			return true
		end,
	}
end, { desc = "Daftar TODO/FIXME di project" })
map("n", "<leader>tt", "<cmd>term<CR><cmd>startinsert<CR>", { desc = "Buka terminal di window aktif" })
map("n", "<leader>sr", "<cmd>split | wincmd L<CR>", { desc = "Split right" })
map("n", "<leader>wm", function()
	if vim.t.nvim_window_focus_zoomed then
		vim.cmd("wincmd =")
	else
		vim.cmd("wincmd |")
		vim.cmd("wincmd _")
	end

	vim.t.nvim_window_focus_zoomed = not vim.t.nvim_window_focus_zoomed
end, { desc = "Besarkan/pulihkan ukuran window" })
map("i", "jk", "<Esc>", { desc = "Kembali ke Normal mode" })

-- Fitur yang punya beberapa keymap dikelompokkan di file terpisah.
require "mappings.git"
require "mappings.workflow"
