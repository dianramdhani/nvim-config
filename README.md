# Konfigurasi Neovim saya

Konfigurasi ini memakai **NvChad v2.5** sebagai dasar, lalu menambahkan pengaturan, plugin, perintah, dan shortcut pribadi. File Lua di sini bisa dibaca dan diubah bertahap; tidak perlu memahami seluruh Lua sekaligus.

## Istilah singkat

- `<leader>` adalah tombol **Space**. Jadi `<leader>ca` berarti tekan `Space`, lalu `c`, lalu `a` secara berurutan.
- `n`, `i`, `x`, dan `t` di konfigurasi berarti Normal, Insert, Visual, dan Terminal mode.
- Sebagian shortcut hanya aktif ketika buffer memakai language server (LSP). Jika shortcut LSP tidak bereaksi, periksa apakah server bahasa untuk file tersebut sudah aktif.

## Peta file

| File atau folder | Kegunaan |
|---|---|
| `init.lua` | Titik awal: menyiapkan lazy.nvim, NvChad, plugin, lalu memuat konfigurasi pribadi. |
| `lua/options.lua` | Opsi Neovim tambahan, termasuk lipatan kode otomatis berbasis Tree-sitter. |
| `lua/autocmds.lua` | Memuat autocmd bawaan NvChad. Tambahkan autocmd pribadi di sini bila memang diperlukan. |
| `lua/chadrc.lua` | Pengaturan UI NvChad, termasuk tema, statusline, dan welcome dashboard. |
| `lua/mappings.lua` | Memuat keymap bawaan NvChad dan keymap pribadi yang umum. |
| `lua/mappings/git.lua` | Shortcut Git dan pilihan file dari commit. |
| `lua/mappings/workflow.lua` | Shortcut Storybook, path, diagnostic, Markdown, dan browser. |
| `lua/commands.lua` | Perintah pribadi seperti `:TutorList` dan `:TutorID1`. |
| `lua/plugins/init.lua` | Daftar plugin tambahan dan kapan plugin dimuat. |
| `lua/configs/lazy.lua` | Pengaturan lazy.nvim, termasuk plugin bawaan yang dinonaktifkan. |
| `lua/configs/conform.lua` | Formatter untuk tiap jenis file dan format otomatis saat menyimpan. |
| `lua/configs/lspconfig.lua` | Language server yang aktif dan shortcut LSP. |
| `lua/configs/markdown_preview.lua` | Pengaturan pratinjau Markdown di browser. |
| `lazy-lock.json` | Versi plugin yang dikunci oleh lazy.nvim; biasanya dikelola otomatis. |
| `docs/tutorials/id/` | Tutorial Vim berbahasa Indonesia. |

### Urutan saat Neovim dibuka

1. `init.lua` menyiapkan lazy.nvim, NvChad, dan daftar plugin.
2. `options.lua`, `autocmds.lua`, dan `commands.lua` dimuat.
3. Keymap dimuat setelahnya. `mappings.lua` memuat keymap NvChad, kemudian keymap pribadi.

Karena pemuatan pribadi terjadi setelah keymap NvChad, shortcut pribadi dapat mengganti shortcut bawaan dengan tombol yang sama. Contohnya `<leader>gt` memakai Git status khusus di konfigurasi ini.

## Shortcut yang sering dipakai

### Berkas dan navigasi

| Shortcut | Kegunaan |
|---|---|
| `Space x` | Tutup buffer aktif. |
| `Space fb` | Pilih buffer yang sedang terbuka. |
| `Space fo` | Cari file yang pernah dibuka. |
| `Space ff` | Cari file di project. |
| `Space fw` | Cari teks di project. |
| `Space e` | Fokus ke panel file NvimTree. |
| `Space tt` | Jalankan `:term` di window aktif. |
| `Space sv` | Buat split, lalu pindahkan window baru ke sisi kanan; setara dengan `:sp` lalu `Ctrl-w L`. |
| `Space h` / `Space v` | Buka terminal NvChad di split horizontal / vertikal. |
| `Ctrl-h/j/k/l` | Pindah antar-window Neovim. |
| `Ctrl-x` di Terminal mode | Keluar dari input terminal ke Normal mode; terminalnya tidak ditutup. |

### Kode dan lipatan

| Shortcut | Kegunaan |
|---|---|
| `gr` | Cari referensi simbol di LSP. |
| `Space ca` | Tampilkan Code Action LSP. |
| `Space ld` | Lihat diagnostic pada baris aktif. |
| `Space cp` | Jika kursor berada di lipatan tertutup, buka dan pilih seluruh baris lipatan. Jika tidak, tampilkan serta salin referensi path dan nomor baris. Dalam Visual mode, salin referensi rentang yang dipilih. |
| `Space ce` | Salin baris aktif beserta diagnostic-nya. Hanya bekerja jika baris itu memiliki diagnostic. |
| `za` | Buka atau tutup lipatan di bawah kursor. |
| `zc` / `zo` | Tutup / buka lipatan di bawah kursor. |
| `Space fm` | Format file melalui formatter yang tersedia. |

Lipatan dibuat otomatis dari struktur Tree-sitter. File dibuka dengan lipatan tampak terbuka, lalu bisa dilipat memakai `za` atau `zc` tanpa menandai rentang dengan `zf` terlebih dahulu. Dukungan lipatan bergantung pada parser bahasa yang terpasang.

### Git

| Shortcut | Kegunaan |
|---|---|
| `Space gt` | Buka daftar perubahan Git di Telescope; Enter membuka file dan daftar tetap terbuka. |
| `Space gT` | Tampilkan daftar file yang berubah di quickfix. |
| `Space gd` | Bandingkan file dengan index Git (perubahan yang belum di-stage). |
| `Space gD` | Bandingkan file dengan `HEAD`. |
| `Space gp` | Pratinjau perubahan hunk di bawah kursor. |
| `Space ga` | Stage seluruh isi folder tempat file aktif berada. Periksa folder yang ditampilkan sebelum melanjutkan workflow Git. |
| `Space gw` | Pilih commit, lalu pilih file yang berubah untuk melihat diff di Telescope. |
| `Space gW` | Pilih commit, lalu tampilkan file yang berubah di quickfix. |

### Alur kerja pribadi lainnya

| Shortcut | Kegunaan |
|---|---|
| `Space sb` | Dari file `index.*`, buka Storybook story terkait jika Storybook lokal aktif. |
| `Space mp` | Tampilkan/sembunyikan pratinjau Markdown di dalam Neovim. |
| `Space md` | Tampilkan/sembunyikan pratinjau Markdown di browser. |
| `Space bo` | Buka route aplikasi lokal terkait di browser. |
| `Space th` | Buka pemilih tema NvChad. |
| `;` | Buka command line Neovim. |
| `jk` di Insert mode | Kembali ke Normal mode. |

> Shortcut bawaan NvChad lainnya bisa dilihat dengan `Space c h` (cheatsheet) atau `:Telescope keymaps`. Shortcut LSP `gr`, `Space ca`, dan `Space ld` tersedia saat LSP terpasang pada file aktif.

## Perintah tutorial

- `:TutorList` menampilkan daftar tutorial.
- `:TutorID1` sampai `:TutorID4` membuka tutorial dasar, editing, gerakan, dan Visual mode.
- `:CopyPath` atau `:CP` menampilkan dan menyalin path serta nomor baris; bisa dipanggil untuk baris aktif atau rentang Visual.
- `:Nvdash` membuka dashboard welcome dengan tabel terpisah untuk shortcut umum dan shortcut NvimTree. Dashboard tampil otomatis saat Neovim dibuka tanpa file.
- `:ReloadUI` memuat ulang tema dan statusline saja. `Space rr` sengaja tidak dipetakan; untuk memuat ulang seluruh konfigurasi, tutup lalu buka kembali Neovim.

## Cara mengubah konfigurasi

### Menambah keymap

Tambahkan keymap umum di `lua/mappings.lua`, keymap Git di `lua/mappings/git.lua`, atau keymap alur kerja pribadi di `lua/mappings/workflow.lua`.

Di file keymap, `map` adalah nama singkat untuk `vim.keymap.set`. Urutan argumennya: mode, tombol, aksi, lalu opsi seperti keterangan (`desc`).

Contoh bentuk keymap:

```lua
map("n", "<leader>th", "<cmd>Telescope themes<CR>", {
  desc = "Buka pemilih tema",
})
```

Baris ini berarti: di Normal mode, tekan `Space` lalu `t` lalu `h`; jalankan perintah Telescope; tampilkan keterangan tersebut di daftar shortcut.

### Mengubah plugin

- Tambahkan atau ubah deklarasi plugin di `lua/plugins/init.lua`.
- Letakkan pengaturan plugin yang lebih panjang di file `lua/configs/` terkait, lalu rujuk dari deklarasi plugin.
- Jangan mengedit `lazy-lock.json` untuk pengaturan biasa. File itu menyimpan versi plugin agar pemasangan berikutnya konsisten.

Setelah mengubah konfigurasi, mulai ulang Neovim untuk memastikan perubahan dimuat. File Lua diformat memakai StyLua dan aturan di `.stylua.toml`.
