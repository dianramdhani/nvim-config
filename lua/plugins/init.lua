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

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
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
