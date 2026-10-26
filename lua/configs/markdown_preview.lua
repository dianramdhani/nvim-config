local M = {}

function M.get_remote_ip()
  if vim.env.SSH_CONNECTION then
    local parts = vim.split(vim.env.SSH_CONNECTION, "%s+")
    if parts[3] and parts[3] ~= "" then
      return parts[3]
    end
  end

  local ts_ip = vim.fn.systemlist("tailscale ip -4 2>/dev/null")[1]
  if ts_ip and ts_ip ~= "" and not ts_ip:match("error") then
    return vim.trim(ts_ip)
  end

  local host_ip = vim.fn.systemlist("hostname -I 2>/dev/null")[1]
  if host_ip and host_ip ~= "" then
    local first_ip = vim.split(vim.trim(host_ip), "%s+")[1]
    if first_ip and first_ip ~= "" then
      return first_ip
    end
  end

  return "localhost"
end

function M.is_remote()
  -- Jika sesi GUI lokal murni (ada DISPLAY/WAYLAND dan bukan via SSH/mosh)
  if (vim.env.DISPLAY or vim.env.WAYLAND_DISPLAY) and not vim.env.SSH_CONNECTION and not vim.env.SSH_CLIENT then
    return false
  end
  return true
end

function M.show_url_dialog(url)
  local width = vim.o.columns
  local needed_lines = math.max(math.ceil(#url / width), 1)
  local height = needed_lines
  local row = math.max(math.floor((vim.o.lines - height) / 2), 0)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  -- Teks URL bersih agar mudah di-copy di HP
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { url })
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

  -- Otomatis salin ke clipboard sistem (+) dan default (")
  pcall(vim.fn.setreg, "+", url)
  pcall(vim.fn.setreg, '"', url)

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<CR>", close, { buffer = buf, nowait = true })

  -- Shortcut 'b' untuk membuka browser Brave di monitor laptop (:0) jika dibutuhkan
  vim.keymap.set("n", "b", function()
    vim.fn.system("DISPLAY=:0 brave-browser " .. vim.fn.shellescape(url) .. " >/dev/null 2>&1 &")
    vim.notify("Membuka Brave di monitor laptop (DISPLAY=:0)...", vim.log.levels.INFO)
    close()
  end, { buffer = buf, nowait = true })

  vim.notify("URL preview disalin ke clipboard! (Tekan 'b' jika ingin buka di layar laptop)", vim.log.levels.INFO)
end

function M.setup()
  vim.g.mkdp_filetypes = { "markdown" }

  local remote = M.is_remote()

  if remote then
    local host_ip = M.get_remote_ip()
    vim.g.mkdp_open_to_the_world = 1
    vim.g.mkdp_open_ip = host_ip
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_browserfunc = "OpenMarkdownPreviewHandler"

    _G.handle_markdown_preview_url = function(url)
      M.show_url_dialog(url)
    end

    vim.cmd [[
      function! OpenMarkdownPreviewHandler(url)
        lua _G.handle_markdown_preview_url(vim.api.nvim_eval('a:url'))
      endfunction
    ]]
  else
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_open_ip = ""
    vim.g.mkdp_browser = "brave-browser"
    vim.g.mkdp_browserfunc = ""
  end
end

return M
