-- Perintah pribadi, tidak bergantung pada plugin.
local tutorial_dir = vim.fs.joinpath(vim.fn.stdpath "config", "docs", "tutorials", "id")

local function buka_tutorial(nama_file)
  local path = vim.fs.joinpath(tutorial_dir, nama_file)
  vim.cmd.edit(vim.fn.fnameescape(path))
end

vim.api.nvim_create_user_command("TutorID1", function()
  buka_tutorial "indonesia-01-dasar.txt"
end, { desc = "Buka tutorial dasar Vim" })

vim.api.nvim_create_user_command("TutorID2", function()
  buka_tutorial "indonesia-02-editing.txt"
end, { desc = "Buka tutorial penyuntingan teks" })

vim.api.nvim_create_user_command("TutorID3", function()
  buka_tutorial "indonesia-03-gerakan.txt"
end, { desc = "Buka tutorial gerakan Vim" })

vim.api.nvim_create_user_command("TutorID4", function()
  buka_tutorial "indonesia-04-visual.txt"
end, { desc = "Buka tutorial Visual mode" })

vim.api.nvim_create_user_command("TutorList", function()
  print "TUTORIAL BAHASA INDONESIA:"
  print ":TutorID1 - Tutorial Dasar Vim"
  print ":TutorID2 - Tutorial Editing Teks"
  print ":TutorID3 - Tutorial Gerakan Lanjutan"
  print ":TutorID4 - Tutorial Mode Visual"
end, { desc = "Lihat daftar tutorial bahasa Indonesia" })
