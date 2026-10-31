-- Bentuk pengaturan mengikuti nvconfig.lua milik NvChad.
-- Lihat https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua untuk opsi yang tersedia.

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.ui = {
	statusline = {
		theme = "default",
		separator_style = "round",
		order = { "mode", "file", "git", "%=", "diagnostics", "cursor" },
		modules = {
			git = function()
				local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
				local root = vim.fs.root(bufnr, { ".git" })
				if not root then
					return ""
				end

				local git_dir = root .. "/.git"
				local stat = vim.uv.fs_stat(git_dir)
				if stat and stat.type == "file" then
					local gitdir = vim.fn.readfile(git_dir)[1]
					gitdir = gitdir and gitdir:match("^gitdir:%s*(.+)$")
					if not gitdir then
						return ""
					end
					if not vim.fs.is_absolute(gitdir) then
						gitdir = root .. "/" .. gitdir
					end
					git_dir = vim.fs.normalize(gitdir)
				end

				local head = vim.fn.readfile(git_dir .. "/HEAD")[1]
				if not head then
					return ""
				end

				local branch = head:match("^ref: refs/heads/(.+)$") or head:sub(1, 7)
				return "%#St_gitIcons#  " .. branch .. " "
			end,
			mode = function()
				local mode = vim.api.nvim_get_mode().mode
				local modes = require("nvchad.stl.utils").modes
				local separators = require("nvchad.stl.utils").separators.round
				local labels = {
					n = "N",
					i = "INS",
					v = "VIS",
					V = "VIS",
					["\22"] = "VIS",
					t = "TERM",
					R = "REP",
				}
				local mode_group = modes[mode] and modes[mode][2] or "Normal"
				local label = labels[mode] or "N"
				return "%#St_" .. mode_group .. "Mode# " .. label
					.. "%#St_" .. mode_group .. "ModeSep#" .. separators.right
					.. "%#ST_EmptySpace#" .. separators.right
			end,
		},
	},
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
