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

-- Dialog floating untuk path reference (GitHub line anchor format)
local function show_path_dialog(text)
  local max_w = math.max(vim.o.columns - 4, 20)
  local width = math.min(math.max(#text + 6, 32), max_w)
  local needed_lines = math.ceil((#text + 4) / math.max(width - 4, 1))
  local height = math.min(needed_lines + 2, math.floor(vim.o.lines * 0.7))
  local row = math.max(math.floor((vim.o.lines - height) / 2) - 1, 1)
  local col = math.max(math.floor((vim.o.columns - width) / 2), 1)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "", "  " .. text, "" })
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " 📋 Path Reference ",
    title_pos = "center",
    footer = " [ESC/q] Close  [y] Copy ",
    footer_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true

  -- Salin otomatis ke clipboard sistem (+) dan default (")
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<CR>", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "y", function()
    vim.fn.setreg("+", text)
    vim.fn.setreg('"', text)
    vim.notify("Copied to clipboard: " .. text, vim.log.levels.INFO)
  end, { buffer = buf, nowait = true })

  -- Kursor di baris teks agar mudah diselect manual di HP
  vim.api.nvim_win_set_cursor(win, { 2, 2 })
end

local function copy_file_reference(is_visual)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer tidak memiliki file", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
  local rel_path = vim.fs.relpath(root, file) or vim.fn.fnamemodify(file, ":.")

  local start_line, end_line
  if is_visual then
    start_line = vim.fn.line "'<"
    end_line = vim.fn.line "'>"
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
  else
    start_line = vim.fn.line "."
    end_line = start_line
  end

  local line_ref
  if start_line == end_line then
    line_ref = string.format("#L%d", start_line)
  else
    line_ref = string.format("#L%d-L%d", start_line, end_line)
  end

  show_path_dialog(rel_path .. line_ref)
end

-- Normal mode: baris saat ini
map("n", "<leader>cp", function()
  copy_file_reference(false)
end, { desc = "Show relative path reference dialog" })

-- Visual mode (x): keluar visual mode dulu dengan <Esc> lalu buka dialog
map("x", "<leader>cp", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
  copy_file_reference(true)
end, { desc = "Show relative path reference dialog" })
