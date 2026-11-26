return {
  {
    "nvim-tree/nvim-tree.lua",
    opts = function(_, opts)
      local api = require "nvim-tree.api"
      -- Layar sempit (HP): tree jadi floating window yang menutupi seluruh layar
      -- dan tertutup setelah file dibuka. Layar lebar tetap memakai split di samping.
      local function is_narrow()
        return vim.o.columns < 80
      end
      local function fullscreen()
        return {
          relative = "editor",
          border = "none",
          row = 0,
          col = 0,
          width = vim.o.columns,
          height = vim.o.lines - vim.o.cmdheight - 1, -- sisakan statusline dan command line
        }
      end
      opts.view = opts.view or {}
      opts.view.float = { enable = false, open_win_config = fullscreen }

      -- nvim-tree membaca float.enable setiap kali window dibuat, jadi mode dipilih tepat sebelum tree dibuka.
      -- Catatan: nvim-tree.config adalah modul internal, cek lagi bila nvim-tree di-update dan ini berhenti bekerja.
      api.events.subscribe(api.events.Event.TreePreOpen, function()
        require("nvim-tree.config").g.view.float.enable = is_narrow()
      end)

      opts.on_attach = function(bufnr)
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "d", api.fs.trash, { buffer = bufnr, desc = "Trash" })
        vim.keymap.set("x", "d", api.fs.trash, { buffer = bufnr, desc = "Trash" })

        local function open()
          local narrow = is_narrow()
          local node = api.tree.get_node_under_cursor()
          api.node.open.edit(nil, { quit_on_open = narrow })
          -- Folder hanya di-expand/collapse, tidak ada file baru yang perlu dirapikan.
          if not narrow or not node or node.nodes then
            return
          end
          -- Dari dashboard, nvim-tree membuka file di split baru; tutup dashboard agar file tampil penuh.
          local function normal_wins()
            return vim.tbl_filter(function(win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end, vim.api.nvim_tabpage_list_wins(0))
          end
          for _, win in ipairs(normal_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "nvdash" and #normal_wins() > 1 then
              vim.api.nvim_win_close(win, false)
            end
          end
        end
        for _, key in ipairs { "<CR>", "o", "<2-LeftMouse>" } do
          vim.keymap.set("n", key, open, { buffer = bufnr, desc = "Open" })
        end
      end

      -- Ikuti perubahan ukuran layar, misalnya HP diputar atau keyboard muncul.
      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("NvimTreeResponsive", { clear = true }),
        callback = function()
          if not api.tree.is_visible() then
            return
          end
          local winid = api.tree.winid()
          local is_float = vim.api.nvim_win_get_config(winid).relative ~= ""
          if is_float ~= is_narrow() then
            -- Berpindah antara HP dan layar lebar: buka ulang dengan mode yang sesuai.
            api.tree.close()
            api.tree.open()
          elseif is_float then
            vim.api.nvim_win_set_config(winid, fullscreen())
          else
            api.tree.resize()
          end
        end,
      })
      return opts
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- Format otomatis sebelum file disimpan.
    opts = require "configs.conform",
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      diff_opts = {
        vertical = false,
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local actions = require "telescope.actions"
      opts.pickers = opts.pickers or {}
      opts.pickers.git_status = {
        layout_strategy = "vertical",
        layout_config = {
          width = 0.95,
          height = 0.95,
          prompt_position = "top",
          mirror = true,
          preview_cutoff = 0,
          preview_height = 0.67, -- Dua pertiga layar untuk pratinjau diff.
        },
        mappings = {
          i = {
            ["<PageDown>"] = actions.preview_scrolling_down,
            ["<PageUp>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-f>"] = actions.preview_scrolling_down,
            ["<C-b>"] = actions.preview_scrolling_up,
          },
          n = {
            ["J"] = actions.preview_scrolling_down,
            ["K"] = actions.preview_scrolling_up,
            ["<PageDown>"] = actions.preview_scrolling_down,
            ["<PageUp>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-f>"] = actions.preview_scrolling_down,
            ["<C-b>"] = actions.preview_scrolling_up,
          },
        },
      }
      return opts
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    opts = {
      ensure_installed = {
        "tree-sitter-cli",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "prettier",
        "stylua",
        "tailwindcss-language-server",
        "typescript-language-server",
      },
    },
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
        "bash",
        "css",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "tsx",
        "typescript",
        "yaml",
        "markdown",
        "markdown_inline",
      })
      return opts
    end,
    config = function(_, opts)
      local treesitter = require "nvim-treesitter"
      treesitter.setup()

      local installed = treesitter.get_installed "parsers"
      local missing = vim.tbl_filter(function(parser)
        return not vim.list_contains(installed, parser)
      end, opts.ensure_installed)

      if #missing > 0 then
        treesitter.install(missing)
      end
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      require("configs.markdown_preview").setup()
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" }, -- Sorotan warna aktif begitu file dibuka.
    cmd = { "TodoTelescope", "TodoQuickFix", "TodoLocList" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
