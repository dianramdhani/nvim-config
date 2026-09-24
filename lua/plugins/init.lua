vim.api.nvim_create_user_command("TutorID1", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/plugins/tutor/id/indonesia-01-dasar.txt")
end, { desc = "Buka Tutorial Dasar Bahasa Indonesia" })

vim.api.nvim_create_user_command("TutorID2", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/plugins/tutor/id/indonesia-02-editing.txt")
end, { desc = "Buka Tutorial Editing Bahasa Indonesia" })

vim.api.nvim_create_user_command("TutorID3", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/plugins/tutor/id/indonesia-03-gerakan.txt")
end, { desc = "Buka Tutorial Gerakan Bahasa Indonesia" })

vim.api.nvim_create_user_command("TutorID4", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/plugins/tutor/id/indonesia-04-visual.txt")
end, { desc = "Buka Tutorial Visual Bahasa Indonesia" })

vim.api.nvim_create_user_command("TutorList", function()
  print("📚 TUTORIAL BAHASA INDONESIA:")
  print(":TutorID1 - Tutorial Dasar Vim")
  print(":TutorID2 - Tutorial Editing Teks")
  print(":TutorID3 - Tutorial Gerakan Lanjutan") 
  print(":TutorID4 - Tutorial Mode Visual")
end, { desc = "Lihat daftar tutorial Indonesia" })

return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
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
          preview_height = 0.67, -- 2/3 layar untuk preview diff
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

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "css-variables-language-server",
        "tailwindcss-language-server",
        "eslint-lsp",
        "prettierd",
        "json-lsp",
        "lua-language-server",
        "stylelint-lsp",
      },
    },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
