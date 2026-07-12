# Catatan Patch — Sprint 1 (Blocker + Crash Fix + Quick Wins)

**Tanggal:** 12 Juli 2026  
**Commit Base:** `e633a80`  
**File ZIP:** `daoji_sprint1_patch.zip`  
**Total File:** 12 file (11 modifikasi + 1 file baru)

---

## Cara Mengaplikasikan Patch

1. Extract ZIP ke root project (`life-tree/app/`).
2. File akan otomatis overwrite yang lama sesuai struktur folder.
3. Jalankan:
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   flutter test
   ```

---

## Ringkasan Perubahan per Tugas

### T1.1 — Safety Card Android Queries + Fallback
**File:**
- `android/app/src/main/AndroidManifest.xml`
- `lib/src/features/safety/safety_card_view.dart`

**Perubahan:**
- Menambahkan `<queries>` untuk `tel:`, `https:`, `http:`, `whatsapp:` + explicit package `com.whatsapp`.
- Mengganti pattern `canLaunchUrl` + `launchUrl` menjadi `try-catch` + `launchUrl` langsung.
- Menambahkan `_showManualCallFallback()` dialog kalau dialer gagal dibuka.

**Catatan:**
- Tidak ada file yang perlu dihapus.
- Method `_showCallMockDialog` lama tetap dipertahankan untuk backward compat.

---

### T1.2 — Value Mirror `late final` Retry Crash
**File:**
- `lib/src/features/value_compass/value_mirror_session_view.dart`

**Perubahan:**
- Baris 35: `late final Future<List<dynamic>> _sessionFuture;` → `late Future<List<dynamic>> _sessionFuture;`
- Menghapus keyword `final` agar bisa di-assign ulang saat retry.

**Catatan:**
- Fix 1 baris, zero side effect.

---

### T1.3 — Soft-Delete Habit Re-Check + Atomic Counter
**File:**
- `lib/src/features/habit/services/habit_log_service.dart`

**Perubahan:**
- `markDone`: Menambahkan idempotency guard (`log.status == Done && deletedAt == null` → return).
- `markDone`: Mengganti counter increment dari `habit.lifetimeDoneCount + 1` (stale object) menjadi atomic SQL `UPDATE habits SET lifetime_done_count = lifetime_done_count + 1`.
- `markUnchecked`: Mengganti counter decrement menjadi atomic SQL dengan floor 0.
- `markMissedWithReason`: Mengganti counter decrement menjadi atomic SQL dengan floor 0.

**Catatan:**
- Tidak ada schema change — hanya query SQL yang diubah.
- **Regression test wajib:** Check → uncheck → check harus konsisten.

---

### T1.4 — Dashboard Cache Invalidation + Paralelisasi
**File:**
- `lib/src/features/dashboard/dashboard_provider.dart` (modifikasi)
- `lib/src/features/dashboard/dashboard_invalidation.dart` (file **BARU**)

**Perubahan:**
- `dashboardDataProvider`: 6 `await` sequential diganti dengan `Future.wait()` — load time dashboard lebih cepat.
- File baru `dashboard_invalidation.dart`: Helper `invalidateDashboardGraph(WidgetRef ref)` untuk invalidate cascade semua child provider.

**Catatan:**
- File `dashboard_invalidation.dart` adalah **file baru** — perlu di-import di call sites:
  - `dashboard_view.dart`
  - `add_habit_view.dart`
  - `growth_map_widget.dart`
  - `habit_log_service.dart` (opsional, jika ingin auto-invalidate setelah toggle)
- Contoh import:
  ```dart
  import 'features/dashboard/dashboard_invalidation.dart';
  // ...
  invalidateDashboardGraph(ref);
  ```

---

### T1.5 — SQLCipher Research Spike
**Status:** Tidak ada kode fix — spike dilakukan di branch terpisah.

---

### T1.6 — Wellness Prompt Cap Fix
**File:**
- `lib/src/features/weekly_pulse/weekly_pulse_view.dart`

**Perubahan:**
- Baris ~445: Kondisi `if (isLowMood)` diganti menjadi `if (shouldLogPrompt)`.
- `shouldLogPrompt` sudah dihitung sebelumnya (low mood + ≥24 jam sejak prompt terakhir).

**Catatan:**
- One-liner fix, zero side effect.

---

### T1.7 — iOS Branding "Daoji"
**File:**
- `ios/Runner/Info.plist`

**Perubahan:**
- `CFBundleDisplayName`: `"Life Tree"` → `"Daoji"`

**Catatan:**
- Perlu rebuild iOS setelah apply patch.

---

### T1.8 — Marketplace `_seedIfEmpty()` Flag
**File:**
- `lib/src/features/marketplace/marketplace_service.dart`

**Perubahan:**
- Menambahkan `bool _seeded = false;` di `LocalMarketplaceService`.
- `_seedIfEmpty()` sekarang skip jika `_seeded == true`.
- Setelah seed berhasil, `_seeded = true`.

**Catatan:**
- 4 query ekstra per operasi marketplace dihilangkan setelah seed pertama.

---

### T1.9 — Onboarding Redirect Loop Guard
**File:**
- `lib/src/core/routing/router.dart`

**Perubahan:**
- Kondisi `if (!value)` diganti menjadi `if (!value && !isGoingToOnboarding)`.
- Mencegah redirect ke `/onboarding` saat user sudah berada di `/onboarding`.

**Catatan:**
- GoRouter 17.x sebenarnya sudah handle gracefully, tapi pattern ini lebih clean.

---

### T1.10 — Silent Catch → Logging (Batch 1)
**File:**
- `lib/src/features/thinking_canvas/thinking_canvas_state.dart`

**Perubahan:**
- `_loadPrefs()`: `catch (_)` → `catch (e, stackTrace)` dengan `debugPrint`.
- `_persistPrefs()`: `catch (_)` → `catch (e, stackTrace)` dengan `debugPrint`.
- `_scheduleDraftSave()`: `catch (_)` → `catch (e, stackTrace)` dengan `debugPrint`.
- `clearCanvas()`: Menambahkan `draftService.deleteDraft()` dengan try-catch.

**Catatan:**
- Tidak ada perubahan behavior — hanya menambahkan logging.
- `clearCanvas()` sekarang benar-benar menghapus draft dari database.

---

### T1.11 — Notification Permission Timing
**File:**
- `lib/src/core/services/notification_service.dart`

**Perubahan:**
- `initialize()`: `requestAlertPermission: true` → `false` (iOS).
- `initialize()`: Tidak lagi memanggil `requestNotificationsPermission()` (Android).
- Menambahkan method baru `static Future<bool> requestPermission()` untuk dipanggil saat user enable reminder pertama.

**Catatan:**
- **Call site yang perlu diupdate:** `add_habit_view.dart` — panggil `NotificationService.requestPermission()` sebelum schedule reminder.
- Contoh:
  ```dart
  if (_reminderEnabled) {
    final hasPermission = await NotificationService.requestPermission();
    if (!hasPermission) {
      // Tampilkan dialog edukasi
      return;
    }
  }
  ```

---

## File Baru (Wajib Ada)

| File | Lokasi dalam ZIP |
|------|-----------------|
| `dashboard_invalidation.dart` | `lib/src/features/dashboard/dashboard_invalidation.dart` |

## File Modifikasi

| # | File | Tugas |
|---|------|-------|
| 1 | `android/app/src/main/AndroidManifest.xml` | T1.1 |
| 2 | `lib/src/features/safety/safety_card_view.dart` | T1.1 |
| 3 | `lib/src/features/value_compass/value_mirror_session_view.dart` | T1.2 |
| 4 | `lib/src/features/habit/services/habit_log_service.dart` | T1.3 |
| 5 | `lib/src/features/dashboard/dashboard_provider.dart` | T1.4 |
| 6 | `lib/src/features/weekly_pulse/weekly_pulse_view.dart` | T1.6 |
| 7 | `ios/Runner/Info.plist` | T1.7 |
| 8 | `lib/src/features/marketplace/marketplace_service.dart` | T1.8 |
| 9 | `lib/src/core/routing/router.dart` | T1.9 |
| 10 | `lib/src/features/thinking_canvas/thinking_canvas_state.dart` | T1.10 |
| 11 | `lib/src/core/services/notification_service.dart` | T1.11 |

---

## Yang Perlu Dilakukan Setelah Apply Patch

### 1. Update Call Sites (Manual)
File berikut perlu diupdate secara manual untuk menggunakan `invalidateDashboardGraph`:
- `lib/src/features/dashboard/dashboard_view.dart`
- `lib/src/features/habit/add_habit_view.dart`
- `lib/src/features/dashboard/widgets/growth_map_widget.dart`

Contoh:
```dart
import '../dashboard_invalidation.dart';
// ...
await service.markDone(habit: habit, date: now);
invalidateDashboardGraph(ref); // ganti dari ref.invalidate(dashboardDataProvider)
```

### 2. Update Call Site Notification Permission (Manual)
File berikut perlu diupdate:
- `lib/src/features/habit/add_habit_view.dart`

Contoh:
```dart
if (_reminderEnabled) {
  final hasPermission = await NotificationService.requestPermission();
  if (!hasPermission) {
    _showPermissionDeniedDialog();
    return;
  }
}
```

### 3. Build & Test
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

### 4. Test Manual Wajib
- [ ] Safety Card: Tap "Hubungi 119" → dialer terbuka (Android 11+)
- [ ] Safety Card: Tap "Chat WhatsApp" → WhatsApp terbuka
- [ ] Value Mirror: Tap retry setelah error → tidak crash
- [ ] Habit: Check → uncheck → check → counter konsisten
- [ ] Dashboard: Toggle habit → dashboard update dalam <500ms
- [ ] Weekly Pulse: Submit dengan mood rendah 2x dalam 1 jam → prompt hanya 1x
- [ ] iOS: App label = "Daoji"
- [ ] Marketplace: Buka marketplace 2x → seed hanya 1x
- [ ] Thinking Canvas: Tulis draft → clear canvas → kill app → buka lagi → draft hilang
- [ ] Notification: Fresh install → tidak ada dialog permission di startup

---

## Yang Sengaja Tidak Diinclude di Sprint 1

| Tugas | Alasan |
|-------|--------|
| Timezone detection | Memerlukan dependency baru (`flutter_timezone`) — ditunda ke Sprint 2 |
| SQLCipher implementation | Spike terpisah — effort 8-12 jam, risk HIGH |
| Test code baru | Belum dibuat — akan dibuat setelah fix stabil |
| `dashboard_view.dart` call site update | Perlu manual review — tidak aman di-patch otomatis |
| `add_habit_view.dart` permission call site | Perlu manual review — tidak aman di-patch otomatis |

---

*Patch ini siap di-copy-replace. Backup repository sebelum apply.*
