-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "decay",

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
