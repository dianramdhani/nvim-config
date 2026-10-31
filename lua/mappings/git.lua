-- Keymap dan alur kerja Git.
local map = vim.keymap.set

-- Perbandingan file menggunakan Gitsigns.
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Bandingkan perubahan yang belum di-stage" })
map("n", "<leader>gD", "<cmd>Gitsigns diffthis HEAD<CR>", { desc = "Bandingkan file dengan HEAD" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Pratinjau perubahan di bawah kursor" })
map("n", "<leader>ga", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer ini belum memiliki file", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(file, ".git")
  if not root then
    vim.notify("File ini tidak berada di dalam repository Git", vim.log.levels.WARN)
    return
  end

  local directory = vim.fs.dirname(file)
  local relative_directory = vim.fs.relpath(root, directory) or "."
  local result = vim.system({ "git", "add", "--", relative_directory .. "/" }, { cwd = root }):wait()

  if result.code == 0 then
    vim.notify("Git add: " .. relative_directory .. "/", vim.log.levels.INFO)
  else
    vim.notify(result.stderr ~= "" and result.stderr or "git add gagal", vim.log.levels.ERROR)
  end
end, { desc = "Stage folder tempat file aktif berada" })
map("n", "<leader>gt", function()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local cwd = vim.fs.root(vim.fn.getcwd(), { ".git" }) or vim.fn.getcwd()
  local make_git_status_entry = require("telescope.make_entry").gen_from_git_status { cwd = cwd }
  require("telescope.builtin").git_status {
    cwd = cwd,
    layout_strategy = "vertical",
    layout_config = {
      width = 0.95,
      height = 0.95,
      prompt_position = "top",
      mirror = true,
      preview_cutoff = 0,
      preview_height = 0.67, -- 2/3 layar untuk preview diff
    },
    entry_maker = function(entry)
      local git_entry = make_git_status_entry(entry)
      if git_entry then
        return git_entry
      end
    end,
    attach_mappings = function(prompt_bufnr, map_inner)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        local picker = action_state.get_current_picker(prompt_bufnr)
        if entry and entry.path and vim.api.nvim_win_is_valid(picker.original_win_id) then
          vim.api.nvim_win_call(picker.original_win_id, function()
            vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
          end)
        end
      end)
      map_inner({ "i", "n" }, "<Esc>", actions.close, { desc = "Tutup daftar Git" })
      -- Shortcut berikut menggeser pratinjau.
      map_inner({ "i", "n" }, "<PageDown>", actions.preview_scrolling_down)
      map_inner({ "i", "n" }, "<PageUp>", actions.preview_scrolling_up)
      map_inner({ "i", "n" }, "<C-d>", actions.preview_scrolling_down)
      map_inner({ "i", "n" }, "<C-u>", actions.preview_scrolling_up)
      map_inner({ "i", "n" }, "<C-f>", actions.preview_scrolling_down)
      map_inner({ "i", "n" }, "<C-b>", actions.preview_scrolling_up)
      -- Di Normal mode, J dan K juga menggeser pratinjau.
      map_inner("n", "J", actions.preview_scrolling_down)
      map_inner("n", "K", actions.preview_scrolling_up)
      return true
    end,
  }
end, { desc = "Buka daftar perubahan Git di Telescope" })
map("n", "<leader>gT", function()
  local cwd = vim.fs.root(vim.fn.getcwd(), { ".git" }) or vim.fn.getcwd()
  local result = vim
    .system({
      "git",
      "-C",
      cwd,
      "status",
      "--porcelain=v1",
      "-z",
      "--untracked-files=all",
      "--no-renames",
    }, { text = true })
    :wait()
  if result.code ~= 0 then
    vim.notify(result.stderr ~= "" and result.stderr or "git status gagal", vim.log.levels.ERROR)
    return
  end

  local items = {}
  for entry in result.stdout:gmatch "([^%z]+)%z" do
    local status, file = entry:match "^(..) (.*)$"
    if status then
      items[#items + 1] = { filename = vim.fs.joinpath(cwd, file), lnum = 1, text = status }
    end
  end

  vim.fn.setqflist({}, " ", { title = "Git status", items = items })
  vim.cmd "copen"
end, { desc = "Tampilkan perubahan Git di quickfix" })
local function choose_commit(on_select)
  local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
  local entries = {}
  for _, line in ipairs(vim.fn.systemlist { "git", "-C", root, "log", "--format=%H%x09%cr%x09%s" }) do
    local sha, time, message = line:match "^(%x+)\t([^\t]+)\t(.*)$"
    if sha then
      local label = message .. " · " .. time
      entries[#entries + 1] = { value = sha, msg = message, display = label, ordinal = label }
    end
  end

  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values
  require("telescope.pickers")
    .new({}, {
      prompt_title = "Pilih commit",
      finder = require("telescope.finders").new_table {
        results = entries,
        entry_maker = function(entry)
          return entry
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map_picker)
        local show_files = function()
          local commit = action_state.get_selected_entry()
          if not commit then
            return
          end
          actions.close(prompt_bufnr)
          local files =
            vim.fn.systemlist { "git", "-C", root, "show", "--format=", "--name-only", "--first-parent", commit.value }
          on_select(commit, root, files)
        end
        map_picker("i", "<CR>", show_files)
        map_picker("n", "<CR>", show_files)
        return true
      end,
    })
    :find()
end

map("n", "<leader>gw", function()
  choose_commit(function(commit, root, files)
    local file_entries = {}
    for _, file in ipairs(files) do
      if file ~= "" then
        file_entries[#file_entries + 1] = {
          value = file,
          filename = vim.fs.joinpath(root, file),
          display = file,
          ordinal = file,
        }
      end
    end
    local conf = require("telescope.config").values
    require("telescope.pickers")
      .new({}, {
        prompt_title = "File dalam " .. commit.msg,
        layout_strategy = "vertical",
        layout_config = {
          width = 0.95,
          height = 0.95,
          prompt_position = "top",
          mirror = true,
          preview_cutoff = 0,
          preview_height = 0.67,
        },
        finder = require("telescope.finders").new_table {
          results = file_entries,
          entry_maker = function(entry)
            return entry
          end,
        },
        sorter = conf.generic_sorter {},
        previewer = require("telescope.previewers").new_buffer_previewer {
          title = "Diff commit",
          define_preview = function(self, entry)
            local diff = vim.fn.systemlist {
              "git",
              "-C",
              root,
              "show",
              "--format=",
              "--no-ext-diff",
              "--no-color",
              "--first-parent",
              commit.value,
              "--",
              entry.value,
            }
            vim.api.nvim_buf_set_lines(
              self.state.bufnr,
              0,
              -1,
              false,
              #diff > 0 and diff or { "(Diff teks tidak tersedia)" }
            )
            vim.bo[self.state.bufnr].filetype = "diff"
          end,
        },
        attach_mappings = function(_, map_picker)
          local actions = require "telescope.actions"
          map_picker({ "i", "n" }, "<PageDown>", actions.preview_scrolling_down)
          map_picker({ "i", "n" }, "<PageUp>", actions.preview_scrolling_up)
          map_picker({ "i", "n" }, "<C-d>", actions.preview_scrolling_down)
          map_picker({ "i", "n" }, "<C-u>", actions.preview_scrolling_up)
          map_picker({ "i", "n" }, "<C-f>", actions.preview_scrolling_down)
          map_picker({ "i", "n" }, "<C-b>", actions.preview_scrolling_up)
          map_picker("n", "J", actions.preview_scrolling_down)
          map_picker("n", "K", actions.preview_scrolling_up)
          return true
        end,
      })
      :find()
  end)
end, { desc = "Pilih file dari commit untuk melihat diff di Telescope" })

map("n", "<leader>gW", function()
  choose_commit(function(commit, root, files)
    local items = {}
    for _, file in ipairs(files) do
      if file ~= "" then
        items[#items + 1] = { filename = vim.fs.joinpath(root, file), lnum = 1 }
      end
    end
    vim.fn.setqflist({}, " ", { title = "File dalam " .. commit.msg, items = items })
    vim.cmd "copen"
  end)
end, { desc = "Pilih file dari commit untuk quickfix" })
