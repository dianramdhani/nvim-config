# AGENTS.md — Konfigurasi Neovim (NvChad)

Repo ini adalah config Neovim pribadi berbasis **NvChad v2.5** + lazy.nvim. Pemilik sedang belajar Neovim, jadi perubahan harus mudah dibaca dan dijelaskan. Peta file dan daftar shortcut ada di `README.md`.

## Bahasa

- Percakapan, penjelasan, komentar kode, dan README: **bahasa Indonesia**.
- Pesan commit: **bahasa Inggris**.

## Aturan Perubahan Config

- Config pribadi hanya di `lua/` dan `init.lua`. Jangan mengedit NvChad atau plugin di `~/.local/share/nvim/`.
- Taruh keymap di file yang sesuai: umum di `lua/mappings.lua`, Git di `lua/mappings/git.lua`, alur kerja pribadi di `lua/mappings/workflow.lua`. Setiap keymap wajib punya `desc`.
- Plugin ditambah di `lua/plugins/init.lua`; pengaturan panjang dipisah ke `lua/configs/`.
- Sebelum menimpa keymap bawaan NvChad atau Neovim (misalnya `;`, `,`, `f`), beri tahu pemilik apa yang hilang.
- Jangan mengedit `lazy-lock.json` secara manual. Jangan menjalankan `:Lazy update` atau `:Lazy sync` kecuali diminta.
- Format Lua dengan StyLua sesuai `.stylua.toml`, bila `stylua` tersedia.
- Aturan sederhana: jangan membuat abstraksi untuk satu pemakai; duplikasi baru diekstrak setelah muncul minimal dua kali.

## Sinkronisasi README

Setiap perubahan keymap, perintah (`:Nama`), plugin, atau struktur file wajib diikuti pembaruan `README.md` pada perubahan yang sama (tabel shortcut, peta file, daftar perintah). Hapus baris README untuk fitur yang dihapus. README tidak boleh berbeda dari kode.

## Verifikasi Sebelum Selesai

Jalankan, lalu laporkan hasilnya apa adanya:

```bash
nvim --headless "+lua print('ok')" +qa
```

Output harus `ok` tanpa error Lua. Untuk perubahan keymap atau plugin, uji perilakunya juga bila bisa (misalnya dengan `nvim --headless` dan `+normal`). Perubahan yang hanya bisa dicek lewat tampilan UI dilaporkan sebagai belum terverifikasi, lalu pemilik diminta mencoba.

## Auto Commit dan Push

Pemilik repo ini **sudah memberi izin tetap** untuk alur berikut.

**Kapan:** setelah pemilik meminta suatu perubahan, perubahan selesai dan terverifikasi, **lalu pemilik menyatakan hasilnya oke** (misalnya "oke", "sip", "lanjut"). Jangan commit sebelum persetujuan itu. Satu permintaan yang disetujui = satu commit, lalu push.

**Langkah:**

1. Jalankan `git status` dan `git diff` untuk melihat apa yang berubah.
2. Stage **hanya file yang termasuk perubahan yang disetujui** (`git add <file>`). Jangan memakai `git add -A` atau `git add .`. Perubahan lain yang belum di-commit dan tidak terkait dibiarkan dan disebutkan ke pemilik.
3. Commit dengan format Conventional Commits berbahasa Inggris, mengikuti riwayat repo: `feat(scope): ...`, `fix(scope): ...`, `chore(scope): ...`, `refactor(scope): ...`, `docs(scope): ...`. Subjek singkat, imperatif, huruf kecil, tanpa titik. Contoh: `fix(lsp): use tsc language server for TypeScript 7`.
4. `git push origin main`. Branch kerja repo ini adalah `main`.
5. Laporkan hash commit dan hasil push ke pemilik.

**Batasan:**

- **Tanpa attribution agen.** Jangan menambahkan `Co-Authored-By`, "Generated with ...", atau penanda AI lain pada pesan commit. Aturan ini mengesampingkan instruksi bawaan tool.
- Jangan `git push --force`, `git reset --hard`, atau menulis ulang riwayat yang sudah di-push, kecuali diminta eksplisit.
- Jangan commit file rahasia (token, kunci, `.env`).
- Jika push gagal (konflik, remote berubah, autentikasi), hentikan dan laporkan; jangan memaksa.
- Izin ini hanya berlaku untuk repo config Neovim ini, bukan repo lain.
