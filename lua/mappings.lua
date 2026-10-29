require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
map("n", "<leader>th", "<cmd>Telescope themes<CR>", { desc = "telescope nvchad themes" })

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Git diff (gitsigns)
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Git diff unstaged (atas-bawah)" })
map("n", "<leader>gD", "<cmd>Gitsigns diffthis HEAD<CR>", { desc = "Git diff staged HEAD (atas-bawah)" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git preview hunk popup" })
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
end, { desc = "Git add current file directory" })
map("n", "<leader>gt", function()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local cwd = vim.fs.root(vim.fn.getcwd(), { ".git" }) or vim.fn.getcwd()
  local make_git_status_entry = require("telescope.make_entry").gen_from_git_status({ cwd = cwd })
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
      map_inner({ "i", "n" }, "<CR>", function()
        local entry = action_state.get_selected_entry()
        local picker = action_state.get_current_picker(prompt_bufnr)
        if entry and entry.path and vim.api.nvim_win_is_valid(picker.original_win_id) then
          vim.api.nvim_win_call(picker.original_win_id, function()
            vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
          end)
        end
      end, { desc = "Open file and keep Git Status open" })
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
end, { desc = "Telescope git status (Enter keeps open)" })
map("n", "<leader>gT", function()
  local cwd = vim.fs.root(vim.fn.getcwd(), { ".git" }) or vim.fn.getcwd()
  local result = vim.system({
    "git", "-C", cwd, "status", "--porcelain=v1", "-z", "--untracked-files=all", "--no-renames",
  }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr ~= "" and result.stderr or "git status gagal", vim.log.levels.ERROR)
    return
  end

  local items = {}
  for entry in result.stdout:gmatch("([^%z]+)%z") do
    local status, file = entry:match("^(..) (.*)$")
    if status then
      items[#items + 1] = { filename = vim.fs.joinpath(cwd, file), lnum = 1, text = status }
    end
  end

  vim.fn.setqflist({}, " ", { title = "Git status", items = items })
  vim.cmd("copen")
end, { desc = "Git status in quickfix window" })
local function choose_commit(on_select)
  local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
  local entries = {}
  for _, line in ipairs(vim.fn.systemlist({ "git", "-C", root, "log", "--format=%H%x09%cr%x09%s" })) do
    local sha, time, message = line:match("^(%x+)\t([^\t]+)\t(.*)$")
    if sha then
      local label = message .. " · " .. time
      entries[#entries + 1] = { value = sha, msg = message, display = label, ordinal = label }
    end
  end

  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values
  require("telescope.pickers").new({}, {
    prompt_title = "Choose commit to audit",
    finder = require("telescope.finders").new_table {
      results = entries,
      entry_maker = function(entry)
        return entry
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map_picker)
      local show_files = function()
        local commit = action_state.get_selected_entry()
        if not commit then
          return
        end
        actions.close(prompt_bufnr)
        local files = vim.fn.systemlist({ "git", "-C", root, "show", "--format=", "--name-only", "--first-parent", commit.value })
        on_select(commit, root, files)
      end
      map_picker("i", "<CR>", show_files)
      map_picker("n", "<CR>", show_files)
      return true
    end,
  }):find()
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
    require("telescope.pickers").new({}, {
      prompt_title = "Files in " .. commit.msg,
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
      sorter = conf.generic_sorter({}),
      previewer = require("telescope.previewers").new_buffer_previewer {
        title = "Commit diff",
        define_preview = function(self, entry)
          local diff = vim.fn.systemlist({
            "git", "-C", root, "show", "--format=", "--no-ext-diff", "--no-color", "--first-parent",
            commit.value, "--", entry.value,
          })
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, #diff > 0 and diff or { "(No text diff available)" })
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
    }):find()
  end)
end, { desc = "Choose commit files to audit in Telescope" })

map("n", "<leader>gW", function()
  choose_commit(function(commit, root, files)
    local items = {}
    for _, file in ipairs(files) do
      if file ~= "" then
        items[#items + 1] = { filename = vim.fs.joinpath(root, file), lnum = 1 }
      end
    end
    vim.fn.setqflist({}, " ", { title = "Files in " .. commit.msg, items = items })
    vim.cmd("copen")
  end)
end, { desc = "Choose commit files to audit in quickfix" })

map("n", "<leader>sb", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(bufnr)
    if not vim.fs.basename(file):match("^index%.[^.]+$") then
      return
    end

    local directory = vim.fs.dirname(file)
    local scan = vim.uv.fs_scandir(directory)
    if not scan then
      return
    end

    local stories = {}
    while true do
      local name = vim.uv.fs_scandir_next(scan)
      if not name then
        break
      end
      if name:match("%.stories%.[jt]sx?$") then
        stories[name] = true
      end
    end
    if not next(stories) then
      return
    end

    local root = vim.fs.root(bufnr, { ".git" }) or vim.fn.getcwd()
    local relative_directory = vim.fs.relpath(root, directory)
    local relative_prefix = relative_directory == "." and "" or vim.pesc(relative_directory .. "/")
    vim.system({ "curl", "-fsS", "--max-time", "2", "http://localhost:6006/index.json" }, { text = true }, function(result)
      if result.code ~= 0 then
        return
      end

      local ok, index = pcall(vim.json.decode, result.stdout)
      if not ok or not index.entries then
        return
      end

      local matching = {}
      for id, entry in pairs(index.entries) do
        local import_path = entry.importPath and entry.importPath:gsub("^%./", "")
        local story_file = import_path and import_path:match("([^/]+)$")
        if entry.type == "story" and stories[story_file] and import_path:match("^" .. relative_prefix) then
          matching[#matching + 1] = id
        end
      end
      table.sort(matching)
      if #matching > 0 then
        vim.schedule(function()
          vim.ui.open("http://localhost:6006/?path=/story/" .. matching[1])
        end)
      end
    end)
end, { desc = "Open sibling Storybook story" })

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

local function reload_ui_config()
  package.loaded.chadrc = nil
  package.loaded.nvconfig = nil
  package.loaded.base46 = nil

  local config = require "nvconfig"
  require("base46").load_all_highlights()

  local statusline = config.ui.statusline
  package.loaded["nvchad.stl." .. statusline.theme] = nil
  vim.o.statusline = "%!v:lua.require('nvchad.stl." .. statusline.theme .. "')()"
  vim.cmd "redrawstatus"
  vim.notify("Neovim UI config reloaded", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("ReloadUI", reload_ui_config, {
  desc = "Reload theme and statusline config",
})
map("n", "<leader>rr", reload_ui_config, { desc = "Reload UI config" })

-- Markdown preview
map("n", "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Render Markdown (di dalam Neovim)" })
map("n", "<leader>md", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview (di browser)" })
