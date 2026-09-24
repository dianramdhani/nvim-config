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

-- Copy relative path with GitHub anchor line reference (path/to/file#L10-L25)
map({ "n", "v" }, "<leader>cp", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer tidak memiliki file", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
  local rel_path = vim.fs.relpath(root, file) or vim.fn.fnamemodify(file, ":.")

  local mode = vim.fn.mode()
  local start_line, end_line

  if mode:match "[vV\22]" then
    start_line = vim.fn.line "v"
    end_line = vim.fn.line "."
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    -- Keluar dari visual mode kembali ke normal mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)
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

  local result = rel_path .. line_ref

  vim.fn.setreg("+", result)
  vim.fn.setreg('"', result)

  vim.notify("📋 Copied: " .. result, vim.log.levels.INFO)
end, { desc = "Copy relative path with line reference (#L..)" })
