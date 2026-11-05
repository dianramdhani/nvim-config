-- Keymap untuk browser, Storybook, path, dan konteks kode.
local map = vim.keymap.set

map("n", "<leader>sb", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if not vim.fs.basename(file):match "^index%.[^.]+$" then
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
    if name:match "%.stories%.[jt]sx?$" then
      stories[name] = true
    end
  end
  if not next(stories) then
    return
  end

  local root = vim.fs.root(bufnr, { ".git" }) or vim.fn.getcwd()
  local relative_directory = vim.fs.relpath(root, directory)
  local relative_prefix = relative_directory == "." and "" or vim.pesc(relative_directory .. "/")
  vim.system(
    { "curl", "-fsS", "--max-time", "2", "http://localhost:6006/index.json" },
    { text = true },
    function(result)
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
        local story_file = import_path and import_path:match "([^/]+)$"
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
    end
  )
end, { desc = "Buka Storybook untuk komponen ini" })

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
  local text = rel_path .. line_ref
  pcall(vim.fn.setreg, "+", text)
  pcall(vim.fn.setreg, '"', text)
  vim.api.nvim_echo({ { "Copied: " .. text, "MoreMsg" } }, false, {})
end

-- :CopyPath dan :CP menerima baris aktif atau rentang Visual.
vim.api.nvim_create_user_command("CopyPath", function(opts)
  execute_copy_path(opts.line1, opts.line2)
end, { range = true, desc = "Salin referensi path" })

vim.api.nvim_create_user_command("CP", function(opts)
  execute_copy_path(opts.line1, opts.line2)
end, { range = true, desc = "Salin referensi path" })

-- Pada lipatan tertutup, shortcut ini menyalin referensi seluruh lipatan.
map("n", "<leader>cp", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local fold_start = vim.fn.foldclosed(line)

  if fold_start == -1 then
    vim.cmd "CopyPath"
    return
  end

  execute_copy_path(fold_start, vim.fn.foldclosedend(line))
end, { desc = "Salin referensi path atau rentang lipatan" })
map("x", "<leader>cp", ":CopyPath<CR>", { desc = "Salin referensi path rentang terpilih" })

map("n", "<leader>z", "za", { desc = "Buka atau tutup lipatan" })

map("n", "<leader>ce", function()
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    vim.notify("Buffer ini belum disimpan sebagai file", vim.log.levels.WARN)
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local diagnostics = vim.diagnostic.get(buf, { lnum = line - 1 })
  if #diagnostics == 0 then
    vim.notify("Tidak ada diagnostic pada baris ini", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(buf, { ".git" }) or vim.fn.getcwd()
  local path = vim.fs.relpath(root, file) or vim.fn.fnamemodify(file, ":.")
  local lines = { string.format("%s#L%d", path, line), vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1] }
  for _, diagnostic in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diagnostic.severity] or "UNKNOWN"
    local source = diagnostic.source and " (" .. diagnostic.source .. ")" or ""
    lines[#lines + 1] = severity .. source .. ": " .. diagnostic.message
  end

  local text = table.concat(lines, "\n")
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify("Baris dan diagnostic disalin", vim.log.levels.INFO)
end, { desc = "Salin baris beserta diagnostic" })

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
  vim.notify("Konfigurasi UI Neovim dimuat ulang", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("ReloadUI", reload_ui_config, {
  desc = "Muat ulang tema dan statusline",
})

-- Pratinjau Markdown di Neovim atau browser.
map("n", "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", { desc = "Tampilkan/sembunyikan Markdown di Neovim" })
map("n", "<leader>md", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Tampilkan/sembunyikan Markdown di browser" })

map("n", "<leader>bo", function()
  local file = vim.api.nvim_buf_get_name(0)
  local root = vim.fs.root(0, { ".git" })
  if not root then
    vim.notify("File ini tidak berada di dalam repository Git", vim.log.levels.WARN)
    return
  end

  local server = vim.system({ "curl", "-fsS", "--max-time", "2", "http://localhost:5173" }, { text = true }):wait()
  if server.code ~= 0 then
    vim.notify("Port 5173 belum aktif. Jalankan `yarn dev` dulu.", vim.log.levels.WARN)
    return
  end

  local relative = vim.fs.relpath(root, file)
  local route
  if relative and relative:match "^src/routes/.*%.tsx$" then
    route = table.concat(vim.fn.readfile(file), "\n"):match "createFileRoute%s*%(%s*['\"]([^'\"]+)"
  elseif relative and relative:match "^src/features/.*/pages/.*/index%.tsx$" then
    local module = "@/" .. relative:match "^src/(.+)/index%.tsx$"
    local id_route
    for _, route_file in ipairs(vim.fn.globpath(vim.fs.joinpath(root, "src/routes"), "**/*.tsx", false, true)) do
      local source = table.concat(vim.fn.readfile(route_file), "\n")
      if source:find(module, 1, true) then
        local candidate = source:match "createFileRoute%s*%(%s*['\"]([^'\"]+)"
        if candidate then
          if candidate:find "%$" then
            id_route = id_route or candidate:match "^(.-)/%$[^/]+"
          else
            route = candidate
            break
          end
        end
      end
    end
    -- shortcut: halaman create/edit bersama memakai route tanpa ID; tambahkan deteksi konteks bila keduanya perlu dibedakan.
    route = route or id_route
  end

  if not route then
    vim.notify("Route untuk file ini tidak ditemukan", vim.log.levels.WARN)
    return
  end

  route = route:match "^(.-)/%$[^/]+" or route
  route = route:gsub("^/_app", ""):gsub("^/_auth", ""):gsub("/+$", "")
  vim.ui.open("http://localhost:5173" .. (route == "" and "/" or route))
end, { desc = "Buka route aplikasi lokal di browser" })
