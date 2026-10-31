return {
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
}
