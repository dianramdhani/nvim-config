require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Git diff (gitsigns)
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Git diff unstaged (atas-bawah)" })
map("n", "<leader>gD", "<cmd>Gitsigns diffthis HEAD<CR>", { desc = "Git diff staged HEAD (atas-bawah)" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git preview hunk popup" })
map("n", "<leader>gt", function()
  local actions = require "telescope.actions"
  require("telescope.builtin").git_status {
    layout_strategy = "vertical",
    layout_config = {
      width = 0.95,
      height = 0.95,
      prompt_position = "top",
      mirror = true,
      preview_cutoff = 0,
      preview_height = 0.67, -- 2/3 layar untuk preview diff
    },
    attach_mappings = function(_, map_inner)
      -- Scroll preview di insert mode & normal mode
      map_inner({ "i", "n" }, "<PageDown>", actions.preview_scrolling_down)
      map_inner({ "i", "n" }, "<PageUp>", actions.preview_scrolling_up)
      map_inner({ "i", "n" }, "<C-d>", actions.preview_scrolling_down)
      map_inner({ "i", "n" }, "<C-u>", actions.preview_scrolling_up)
      map_inner({ "i", "n" }, "<C-f>", actions.preview_scrolling_down)
      map_inner({ "i", "n" }, "<C-b>", actions.preview_scrolling_up)
      -- Di normal mode (tekan ESC): J dan K untuk scroll preview
      map_inner("n", "J", actions.preview_scrolling_down)
      map_inner("n", "K", actions.preview_scrolling_up)
      return true
    end,
  }
end, { desc = "Telescope git status (preview bawah 2/3 & scrollable)" })

-- Dialog floating untuk path reference (Full width, border none agar bersih di-copy di HP tanpa karakter border)
local function show_path_dialog(text)
  local width = vim.o.columns
  local needed_lines = math.max(math.ceil(#text / width), 1)
  local height = needed_lines
  local row = math.max(math.floor((vim.o.lines - height) / 2), 0)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  -- HANYA isi teks path itu saja (tanpa baris kosong, tanpa padding, tanpa karakter border)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = 0,
    style = "minimal",
    border = "none",
  })

  vim.wo[win].wrap = true
  vim.wo[win].winhighlight = "Normal:Pmenu,NormalFloat:Pmenu"

  -- Salin otomatis ke clipboard sistem (+) dan default (")
  pcall(vim.fn.setreg, "+", text)
  pcall(vim.fn.setreg, '"', text)

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<CR>", close, { buffer = buf, nowait = true })
end

local function execute_copy_path(line1, line2)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer ini belum disimpan sebagai file", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
  local rel_path = vim.fs.relpath(root, file) or vim.fn.fnamemodify(file, ":.")

  local s = line1 or vim.fn.line "."
  local e = line2 or s
  if s > e then
    s, e = e, s
  end

  local line_ref = (s == e) and string.format("#L%d", s) or string.format("#L%d-L%d", s, e)
  show_path_dialog(rel_path .. line_ref)
end

-- Command :CopyPath dan :CP (bisa dipanggil langsung dari command line atau visual range)
vim.api.nvim_create_user_command("CopyPath", function(opts)
  execute_copy_path(opts.line1, opts.line2)
end, { range = true, desc = "Show path reference dialog" })

vim.api.nvim_create_user_command("CP", function(opts)
  execute_copy_path(opts.line1, opts.line2)
end, { range = true, desc = "Show path reference dialog" })

-- Keymap shortcut <leader>cp
map("n", "<leader>cp", "<cmd>CopyPath<CR>", { desc = "Show path reference dialog" })
map("x", "<leader>cp", ":CopyPath<CR>", { desc = "Show path reference dialog" })
