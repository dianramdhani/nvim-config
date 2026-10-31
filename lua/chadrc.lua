-- Bentuk pengaturan mengikuti nvconfig.lua milik NvChad.
-- Lihat https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua untuk opsi yang tersedia.

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "obsidian-ember",

	-- Warna kategori di nvdash: tiap grup punya warna berbeda agar otak
	-- belajar "area warna = topik" tanpa harus membaca header-nya.
	hl_override = {
		-- Header ASCII: kuning hangat seperti "selamat datang"
		NvDashAscii = { fg = "#cba6f7", bold = true }, -- lavender catppuccin
		-- Isi shortcut: teks biasa, tidak mengganggu
		NvDashButtons = { fg = "#cdd6f4" }, -- text catppuccin
		-- Separator / footer: redup, jadi background noise
		NvDashFooter = { fg = "#585b70" }, -- surface2 catppuccin
	},
}

M.ui = {
	statusline = {
		theme = "default",
		separator_style = "round",
		order = { "mode", "file", "git", "%=", "diagnostics" },
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

-- shortcut: daftar ini disalin manual; sinkronkan dengan selected-shortcut.md saat daftar berubah.

-- Helper: key kiri rata kiri lebar 12, key kanan rata kiri lebar 12
-- Format: "  KEY   label        ·  KEY   label"
local function sc(k1, l1, k2, l2)
	if k2 then
		return string.format("  %-10s %-20s·  %-10s %s", k1, l1, k2, l2)
	else
		return string.format("  %-10s %s", k1, l1)
	end
end

-- Tagline campur aduk Indonesia, max 25 huruf, random tiap buka
local taglines = {
	-- coding life
	"git push, doa dulu.",
	"bug lagi? ngopi dulu.",
	"build gagal, kenapa?",
	"prod down, panik dulu.",
	"deploy jam 5 sore, gils.",
	"hotfix malem, kuat.",
	"error 500, bukan salahku.",
	"bug di prod, peluk diri.",
	"testing? langsung deploy.",
	"dokumentasi? YOLO aja.",
	"senior review, gemetar.",
	"conflict merge, sabar.",
	"PR belum di-merge, bro.",
	"portfolio kosong, aduh.",
	"copy paste dari AI lah.",
	"AI replace kita kapan?",
	"chatGPT tau semua nih.",
	"stack overflow is bae.",
	-- kerjaan & kantor
	"meeting lagi? aduh.",
	"rapat pagi, siang, sore.",
	"zoom meeting, kamera off.",
	"mute semua, aman bro.",
	"lembur lagi, bonus mana?",
	"KPI belum nyampe, sis.",
	"review tahunan, deg-deg.",
	"naik jabatan? kapan?",
	"resign atau bertahan?",
	"freelance atau ngantor?",
	"ngantor atau WFH bro?",
	"linkedin update dulu.",
	"interview besok, gas.",
	"rejected lagi, semangat.",
	"absen dulu, ngopi.",
	"deadline besok, santuy.",
	-- ekonomi & dompet
	"harga naik, gaji enggak.",
	"beli bensin, nabung dulu.",
	"listrik naik, fans mati.",
	"beras mahal, lapar ah.",
	"UMR segitu, kos mahal.",
	"KPR impian, UMR nyata.",
	"cicilan lunas kapan nih?",
	"akhir bulan, mode hemat.",
	"gajian bentar lagi, gas.",
	"transfer, eh saldo nol.",
	"paylater numpuk, aduh.",
	"cashback abis, sedih.",
	"promo habis, full price.",
	"diskon 90%? ada syarat.",
	"BPJS nunggak, doain.",
	"dolar naik, client US.",
	"rupiah lemah, sedihnya.",
	"nabung susah, jajan yes.",
	-- politik & sosial
	"janji kampanye mana?",
	"demo lagi? biasa aja.",
	"korupsi? episode baru.",
	"pejabat kena OTT lagi.",
	"anggaran mana, bro?",
	"APBN bocor, biasa nih.",
	"proyek mangkrak lagi.",
	"jalan rusak sejak kapan?",
	"banjir tiap tahun, oke.",
	"polusi? biasa, santuy.",
	"pilkada lagi, siap!",
	-- transportasi & kota
	"macetnya parah, gila.",
	"macet total, rebahan.",
	"commute 3 jam, kuat.",
	"MRT penuh, ojol mahal.",
	"hujan, ojol mahal nih.",
	"ojol atau jalan kaki?",
	"qris, tapi server down.",
	"gopay atau ovo nih?",
	-- makanan & gaya hidup
	"udah makan belum bro?",
	"mie instan lagi, yes.",
	"indomie rebus jam 2.",
	"nasi padang, tapi mahal.",
	"kopi susu tiap hari.",
	"kopi dulu, baru ngoding.",
	"bubble tea lagi, oke.",
	"makan siang, skip.",
	"diet mulai besok, janji.",
	"olahraga? ntar dulu.",
	-- rumahan
	"token listrik mau abis.",
	"laptop panas, aku juga.",
	"wifi lemot, mau nangis.",
	"chat masuk, pura buta.",
	"read, tapi ga bales.",
	-- begadang & sosmed
	"tidur jam 3, bangun 7.",
	"scroll reels, lupa tidur.",
	"doomscrolling sampe pagi.",
	"konten viral, abis gitu.",
	"drakor atau ngoding?",
	"netflix sambil kerja.",
	-- motivasi receh
	"yang penting ketawa.",
	"pusing? makan dulu.",
	"gas, bisa kita bisa!",
	"hari ini harus produktif.",
	"semangat, bro. semangat.",
}
math.randomseed(os.time())
local tagline = taglines[math.random(#taglines)]

-- Rata tengah tagline di bawah ASCII (lebar konten = 26 char)
local ascii_width = 26
local pad = math.floor((ascii_width - #tagline) / 2)
local tagline_centered = string.rep(" ", pad + 2) .. tagline

M.nvdash = {
	load_on_startup = true,

	header = {
		"",
		"   _  _  __  __ ___ __  __",
		"  | \\| | \\ \\/ /|_ _|  \\/  |",
		"  | .` |  \\  / | | | |\\/| |",
		"  |_|\\_|   \\/  |___|_|  |_|",
		tagline_centered,
		"",
	},

	buttons = {
		-- ── LSP ──────────────────────────────────────────────────────────
		{ txt = "  LSP & Code", hl = "NvDashAscii", no_gap = true },
		{ txt = sc("gr", "Cari referensi", "<leader>ca", "Code Action"), hl = "NvDashButtons", no_gap = true },
		{ txt = sc("<leader>ld", "Diagnostic baris"), hl = "NvDashButtons", no_gap = true },
		{ txt = "" },

		-- ── File & Buffer ─────────────────────────────────────────────────
		{ txt = "  File & Buffer", hl = "NvDashAscii", no_gap = true },
		{ txt = sc("<leader>fo", "File terbaru", "<leader>fb", "Buffer aktif"), hl = "NvDashButtons", no_gap = true },
		{ txt = sc("<leader>x", "Tutup buffer", "<leader>cp", "Salin path/fold"), hl = "NvDashButtons", no_gap = true },
		{ txt = "" },

		-- ── Window ─────────────────────────────────────────────────────────
		{ txt = "  Window", hl = "NvDashAscii", no_gap = true },
		{ txt = sc("<leader>wm", "Fokus/pulihkan ukuran"), hl = "NvDashButtons", no_gap = true },
		{ txt = "" },

		-- ── Git ───────────────────────────────────────────────────────────
		{ txt = "  Git", hl = "NvDashAscii", no_gap = true },
		{ txt = sc("<leader>gt", "Status (Telescope)", "<leader>gT", "Status (quickfix)"), hl = "NvDashButtons", no_gap = true },
		{ txt = sc("<leader>gw", "Commit diff (scope)", "<leader>gW", "Commit files (qf)"), hl = "NvDashButtons", no_gap = true },
		{ txt = "" },

		-- ── Fold & Terminal ───────────────────────────────────────────────
		{ txt = "  Fold & Terminal", hl = "NvDashAscii", no_gap = true },
		{ txt = sc("za", "Buka/tutup fold", "zc", "Tutup fold"), hl = "NvDashButtons", no_gap = true },
		{ txt = sc("<C-x>", "Keluar terminal mode"), hl = "NvDashButtons", no_gap = true },
		{ txt = "" },

		-- ── NvimTree ──────────────────────────────────────────────────────
		{ txt = "  NvimTree", hl = "NvDashAscii", no_gap = true },
		{ txt = sc("a", "Buat file/dir", "r", "Rename"), hl = "NvDashButtons", no_gap = true },
		{ txt = sc("D", "Hapus (trash)", "Y", "Salin path relatif"), hl = "NvDashButtons", no_gap = true },
		{ txt = sc("I", "Filter git-ignored", "Tab", "Pratinjau"), hl = "NvDashButtons", no_gap = true },
		{ txt = "" },

		-- ── Footer ────────────────────────────────────────────────────────
		{ txt = "  ch  Cheatsheet lengkap", keys = "ch", cmd = "NvCheatsheet", hl = "NvDashFooter", no_gap = true },
	},
}

-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
