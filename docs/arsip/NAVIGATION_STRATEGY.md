# Navigation Strategy — Daoji

**Status:** Decided (P2-02)
**Last updated:** 28 Juni 2026

## Konteks Masalah

Evaluasi (UX-01) menyoroti bahwa fitur tersebar antara bottom navigation dan layer routing terpisah, sehingga pengguna bingung "di mana fitur X?".

Struktur saat ini:

- **Bottom navigation (4 tab)** — di [main_navigation_shell.dart](../app/lib/src/features/navigation/main_navigation_shell.dart):
  - Beranda (Dashboard)
  - Jurnal
  - Refleksi
  - Profil
- **Route terpisah (push, di luar shell)**:
  - `/add-habit` — Tambah Kebiasaan
  - `/thinking-canvas` — Thinking Canvas
  - `/safety` — Safety Card
  - `/marketplace` — Marketplace
  - `/weekly-pulse` — Weekly Pulse
  - `/decision-journal` — Decision Journal

## Keputusan

**Pertahankan 4 tab bottom navigation.** Menambah tab ke-5 ("Tools") berisiko menambah beban kognitif dan menduplikasi entry point yang sudah ada di dalam tab (mis. Thinking Canvas & Mood sudah dapat diakses lewat Quick Actions di dashboard).

Alasan:
1. **Hindari over-tabbing.** 5+ tab menurunkan kejelasan; 4 tab adalah sweet spot mobile.
2. **Quick Actions sebagai hub.** Entry point untuk fitur sekunder (Thinking Canvas, Jurnal, Add Habit) sudah dikonsolidasikan di panel Quick Actions ([quick_actions_panel.dart](../app/lib/src/features/dashboard/widgets/quick_actions_panel.dart)) pada dashboard.
3. **Route kontekstual tetap push.** Fitur yang muncul kontekstual (Safety Card saat low mood, Weekly Pulse saat Minggu, Decision Journal review) lebih tepat sebagai route yang dipicu kondisi, bukan tab permanen.

## Konvensi yang Disepakati

| Jenis fitur | Pola navigasi |
|-------------|---------------|
| Aktivitas harian inti (dashboard, jurnal, refleksi, profil) | Bottom tab |
| Aksi yang sering tapi bukan tab (tambah habit, thinking canvas, mood) | Quick Actions panel di dashboard |
| Fitur kontekstual / dipicu kondisi (safety, weekly pulse, decision review, marketplace) | `context.push('/route')` dengan banner/alert pemicu di dashboard |

## Tindak Lanjut (opsional, di luar scope saat ini)

- Pastikan setiap route push memiliki AppBar dengan tombol back yang jelas.
- Tambahkan judul konsisten di setiap halaman push agar pengguna tahu posisi mereka.
- Pertimbangkan "command palette" / search global jika jumlah fitur terus bertambah.
