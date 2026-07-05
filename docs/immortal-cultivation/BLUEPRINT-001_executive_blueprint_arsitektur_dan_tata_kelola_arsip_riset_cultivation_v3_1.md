# Executive Blueprint V3.1
## Arsitektur, Tata Kelola, dan Kerangka Implementasi
### Immortal Cultivation / Xianxia / Xiuzhen Research Archive

---

## 1. Informasi Dokumen

| Elemen | Nilai |
|---|---|
| Nama dokumen | Executive Blueprint V3.1 |
| Fungsi dokumen | Dokumen induk arsitektur dan tata kelola proyek riset |
| Cakupan | Seluruh arsip riset modular cultivation |
| Status | Draft operasional |
| Bahasa kerja | Indonesia dengan terminologi teknis lintas bahasa |
| Karakter dokumen | Formal, modular, skalabel, audit-friendly |

---

## 2. Ringkasan Eksekutif

Dokumen ini menetapkan kerangka arsitektur, sistem klasifikasi, aturan tata kelola, prioritas implementasi, dan mekanisme pengendalian mutu untuk arsip riset bertopik **immortal cultivation / xianxia / xiuzhen**.

Rancangan ini dibangun untuk mendukung empat fungsi utama secara simultan:

1. **arsip pengetahuan** tentang cultivation sebagai genre dan sistem budaya;
2. **platform analisis komparatif** antar subgenre, karya, dan era;
3. **basis desain worldbuilding original** untuk novel, komik, game, atau media lain;
4. **kerangka kerja jangka panjang** yang dapat diperluas tanpa cepat runtuh akibat overlap, inflasi scope, atau inkonsistensi terminologi.

Secara struktural, dokumen ini menempatkan proyek pada model **ensiklopedia modular dengan governance aktif**. Cakupan ditetapkan luas secara sadar; pengendalian dilakukan melalui:

- pemisahan domain,
- pemisahan peran file,
- aturan owner concept,
- template bertingkat,
- done criteria,
- milestone,
- minimum viable archive,
- protokol revisi dan versioning.

---

## 3. Tujuan Dokumen

Dokumen ini menetapkan:

- batas dan bentuk proyek;
- sistem identifikasi file;
- taksonomi domain riset;
- struktur hubungan antardokumen;
- standar penyusunan file;
- prioritas dan urutan implementasi;
- mekanisme quality control;
- mekanisme perubahan dan pemeliharaan arsip.

Dokumen ini **bukan** file kajian topik spesifik. Fungsinya adalah sebagai **dokumen induk proyek**.

---

## 4. Pernyataan Cakupan

Arsip mencakup seluruh lapisan berikut:

- fondasi filosofis, religius, dan historis;
- ontologi dan metafisika cultivation;
- sistem progresi, risiko, dan struktur kekuatan;
- jalur dan spesialisasi cultivation;
- worldbuilding makro dan mikro;
- makhluk, flora, resource, artefak, profesi;
- struktur naratif dan craft cultivation fiction;
- studi komparatif antar karya dan subgenre;
- pasar, platform, IP, fandom, dan resepsi;
- toolkit desain original.

Arsip tidak dibatasi hanya pada xianxia klasik. Arsip juga mencakup:

- dark cultivation,
- system cultivation,
- urban/modern cultivation,
- sci-fi / interstellar cultivation,
- hybrid narrative cultivation,
- varian lintas budaya yang relevan.

---

## 5. Prinsip Arsitektur

### 5.1 Prinsip inti

1. **Cakupan dipertahankan luas**, tetapi tidak dibiarkan cair tanpa kontrol.
2. **Tidak semua file setara**; sejumlah file berfungsi sebagai jangkar konseptual.
3. **Setiap konsep besar memiliki owner file**.
4. **Overlap ditangani secara eksplisit**, bukan diabaikan.
5. **Riset dan tata kelola berjalan bersamaan**.
6. **Data pasar diperlakukan sebagai data bergerak**.
7. **Kedalaman ditetapkan bertingkat** sesuai peran file.
8. **Produk minimum tetap harus bernilai mandiri**.

### 5.2 Konsekuensi operasional

- Tidak semua file harus diselesaikan pada Level 3.
- File Living dan Snapshot wajib mengikuti siklus pembaruan.
- File Hub wajib selesai lebih dahulu dibanding file Satellite.
- Seluruh terminologi wajib mengikuti kebijakan pusat di file META.

---

## 6. Model Taksonomi Dokumen

### 6.1 Domain utama

| Kode | Domain | Fungsi utama |
|---|---|---|
| META | Governance & Reference | indeks, metodologi, glosarium, bibliografi, kontrol proyek |
| FOUND | Foundation | akar budaya, sejarah, filsafat, genre dasar |
| CORE | Core Metaphysics | ontologi, hukum dasar, metafisika cultivation |
| SYS | System & Progression | realm, breakthrough, tribulation, aptitude, risiko |
| PATH | Cultivation Paths | jalur, disiplin, spesialisasi, profesi jalur |
| WORLD | Worldbuilding | masyarakat, institusi, budaya, geografi, kosmologi terapan |
| ENT | Entities & Items | flora, fauna, resource, senjata, artefak, profesi teknis |
| NARR | Narrative Structure | tropes, pacing, karakter, tonalitas, bentuk serial |
| COMP | Comparative Analysis | perbandingan sistem, karya, subgenre, pengaruh |
| MRKT | Market & IP | ranking, platform, IP, fandom, resepsi, industri |
| TOOL | Creator Toolkit | template desain original, anti-klise, reverse engineering |

### 6.2 Peran file

| Label | Fungsi |
|---|---|
| Hub | jangkar utama dan rujukan pusat |
| Satellite | file pendukung atau file topik sangat spesifik |
| Bridge | file penghubung dua domain atau lebih |

### 6.3 Status temporal

| Label | Fungsi |
|---|---|
| Stable | relatif final, revisi jarang |
| Living | diperbarui berkala |
| Snapshot | merekam kondisi periode tertentu |
| Draft | masih dalam tahap kerja |

### 6.4 Aturan kombinasi

- `Stable` tidak digabung dengan `Living`.
- `Stable` tidak digabung dengan `Snapshot`.
- `Snapshot` digunakan untuk dokumen berbasis periode atau tanggal.
- `Hub` / `Satellite` / `Bridge` merupakan sumbu fungsi.
- `Stable` / `Living` / `Snapshot` / `Draft` merupakan sumbu temporal.

---

## 7. Sistem Identifikasi File

Format identifikasi file ditetapkan sebagai berikut:

`[DOMAIN]-[NOMOR]_[nama_file].md`

Contoh:
- `META-001_master_index_dan_status_proyek.md`
- `CORE-001_riset_qi_komprehensif.md`
- `WORLD-005_heavenly_court_underworld_reincarnation_dan_birokrasi_kosmik.md`

Keunggulan sistem ini:
- tidak cepat kehabisan slot;
- aman untuk ekspansi;
- mudah ditelusuri berdasarkan domain;
- lebih stabil dibanding blok angka sempit.

---

## 8. Aturan Owner Concept

Setiap konsep besar hanya memiliki **satu file utama pemilik konsep**.

### 8.1 Definisi
Owner concept adalah file yang memiliki otoritas utama untuk mendefinisikan, membatasi, dan menjelaskan konsep tertentu secara inti.

### 8.2 Aturan
- File owner menjelaskan inti konsep secara penuh.
- File non-owner hanya menyentuh konsep seperlunya lalu merujuk ke file owner.
- Bila dua file berisiko membahas konsep yang sama, prioritas ditetapkan dalam `META-003`.

### 8.3 Contoh

| Konsep | Owner file | File lain yang hanya menyentuh |
|---|---|---|
| Qi | CORE-001 | CORE-002, CORE-003, SYS-007, COMP-002 |
| Dao sebagai ontologi | CORE-004 | CORE-006, SYS-010, PATH-001 |
| Heart demon | SYS-003 | SYS-002, NARR-003, COMP-006 |
| Herbs spiritual | ENT-004 | PATH-004, WORLD-004 |
| Realm & breakthrough | SYS-001 | SYS-002, COMP-005, TOOL-003 |

---

## 9. Standar Struktur File

### 9.1 Template penuh untuk Hub files
Template penuh wajib memuat komponen berikut:

1. ID file
2. Judul file
3. Domain dan status
4. Pertanyaan inti
5. Signifikansi topik
6. Batas file
7. Hal yang tidak dibahas
8. Owner concept
9. Akar filosofis/historis/genre
10. Terminologi penting
11. Variasi antar subgenre/karya
12. Fungsi worldbuilding
13. Fungsi sistem kekuatan
14. Implikasi naratif, sosial, psikologis
15. Trope umum
16. Klise yang perlu dihindari
17. Peluang inovasi
18. Karya acuan
19. File terkait
20. Pertanyaan riset yang belum terjawab
21. Source policy singkat
22. Last updated / version

### 9.2 Template ringkas untuk Satellite files
1. ID file
2. Judul file
3. Domain dan status
4. Pertanyaan inti
5. Fokus file
6. Hal yang tidak dibahas
7. Terminologi kunci
8. Owner concept
9. Karya acuan
10. File terkait
11. Last updated

### 9.3 Template data untuk Living / Snapshot market files
1. ID file
2. Periode/tanggal snapshot
3. Pertanyaan inti
4. Metode pengumpulan data
5. Sumber utama
6. Metrik
7. Temuan utama
8. Perubahan dari periode sebelumnya
9. Keterbatasan data
10. File terkait

---

## 10. Standar Kualitas (Done Criteria)

| Level | Persyaratan minimum |
|---|---|
| Level 1 | 1 draft, 1 revisi, min. 3 sumber atau 3 karya acuan, batas file jelas |
| Level 2 | 1 draft, 2 revisi, min. 5 sumber atau 5 karya acuan, overlap dicek, owner concept jelas |
| Level 3 | 1 draft, 3 revisi, min. 8–12 sumber atau 8+ karya acuan, cross-check lintas domain, siap jadi rujukan inti |

### Ketentuan tambahan
- File Hub idealnya mencapai minimal Level 2 sebelum ekspansi besar ke file satelit.
- File Living wajib memiliki tanggal pembaruan.
- File Snapshot wajib menyebut periode snapshot secara eksplisit.

---

## 11. Source Policy per Domain

| Domain | Kebijakan sumber |
|---|---|
| FOUND | teks klasik, studi agama, sejarah budaya, akademik |
| CORE / SYS | tradisi, karya primer, analisis genre, observasi sistematis |
| PATH / WORLD / ENT | korpus karya primer, observasi tema, sumber sekunder tematik |
| NARR | karya primer, teori naratif, observasi serialisasi |
| COMP | korpus benchmark wajib, tabel komparatif, sintesis |
| MRKT | platform resmi, chart, laporan industri, snapshot tanggal |
| TOOL | sintesis dari domain lain; bukan klaim sejarah primer |

---

## 12. Register Domain dan File Utama

### 12.1 META — Governance & Reference

| ID | Judul | Status | Fungsi |
|---|---|---|---|
| META-001 | master_index_dan_status_proyek.md | Hub + Living | indeks, level, status, owner registry |
| META-002 | metodologi_korpus_dan_konvensi_riset.md | Hub + Stable | ruang lingkup, standar istilah, aturan proyek |
| META-003 | batas_scope_owner_matrix_dan_relasi_antar_file.md | Hub + Living | overlap matrix, owner matrix, aturan rujukan |
| META-004 | korpus_benchmark_dan_alasan_pemilihan.md | Hub + Living | 10–20 karya benchmark |
| META-005 | glosarium_istilah_cultivation.md | Hub + Living | kamus istilah |
| META-006 | bibliografi_peta_sumber_dan_klasifikasi_referensi.md | Hub + Living | peta sumber |
| META-007 | protokol_revisi_verifikasi_dan_versioning.md | Hub + Stable | revisi, verifikasi, versioning |
| META-008 | estimasi_effort_dan_throughput_planning.md | Hub + Living | kapasitas kerja, ritme, beban produksi |
| META-009 | minimum_viable_archive_dan_milestone.md | Hub + Stable | MVA dan milestone |
| META-010 | tagging_dependency_graph_dan_reading_map.md | Stable | tagging dan dependency graph |
| META-011 | indeks_contoh_karya_per_konsep.md | Living | contoh penerapan konsep |
| META-012 | quickstart_pembaca_baru_dan_orientation_map.md | Stable | entry point pembaca baru |

### 12.2 FOUNDATION — Akar Genre dan Budaya

| ID | Judul | Status |
|---|---|---|
| FOUND-001 | fondasi_genre_cultivation.md | Hub + Stable |
| FOUND-002 | xianxia_wuxia_xiuzhen_xiuxian_xuanhuan_shenmo.md | Hub + Stable |
| FOUND-003 | akar_daoisme_buddhisme_konfusianisme_dan_folk_religion.md | Hub + Stable |
| FOUND-004 | neidan_waidan_dan_alkimia_tubuh_tradisi_ke_fiksi.md | Stable |
| FOUND-005 | teks_klasik_mitologi_dan_mesin_imajinasi_genre.md | Stable |
| FOUND-006 | konsep_keabadian_transendensi_dan_xian_dalam_tradisi_tiongkok.md | Stable |
| FOUND-007 | heaven_earth_human_triad_dan_kosmologi_dasar.md | Stable |
| FOUND-008 | bahasa_terjemahan_dan_masalah_terminologi_cultivation.md | Hub + Stable |
| FOUND-009 | varian_lintas_budaya_murim_senjutsu_tu_tien_dan_hibrida_asia.md | Stable |
| FOUND-010 | sejarah_literatur_web_tiongkok_dan_lahirnya_cultivation_modern.md | Stable |

### 12.3 CORE — Ontologi dan Metafisika Dasar

| ID | Judul | Status |
|---|---|---|
| CORE-001 | riset_qi_komprehensif.md | Hub + Stable |
| CORE-002 | jing_qi_shen_dan_tiga_harta.md | Hub + Stable |
| CORE-003 | dantian_meridian_acupoints_dan_sirkulasi_energi.md | Hub + Stable |
| CORE-004 | dao_sebagai_ontologi_hukum_kosmik_dan_enlightenment.md | Hub + Stable |
| CORE-005 | yin_yang_wuxing_dan_logika_transformasi.md | Stable |
| CORE-006 | dao_heart_true_meaning_true_essence_intent_dan_domain.md | Stable |
| CORE-007 | nama_sejati_bahasa_suci_mantra_true_words_dan_runic_language.md | Stable |
| CORE-008 | space_time_void_dan_hukum_dimensional.md | Stable |
| CORE-009 | fate_destiny_mandate_dan_jalinan_nasib.md | Stable |
| CORE-010 | luck_fortune_luck_stealing_dan_probabilitas_sakral.md | Stable |
| CORE-011 | karma_causality_dan_sebab_akibat_kosmik.md | Stable |
| CORE-012 | identity_soul_signature_memory_continuity_dan_personhood.md | Bridge + Stable |
| CORE-013 | temporal_experience_time_dilation_dan_nostalgia_kosmik.md | Bridge + Stable |

### 12.4 SYSTEM — Progresi dan Risiko

| ID | Judul | Status |
|---|---|---|
| SYS-001 | realm_breakthrough_dan_struktur_kultivasi.md | Hub + Stable |
| SYS-002 | heavenly_tribulation_eksternal_dan_harga_kekuatan.md | Hub + Stable |
| SYS-003 | heart_demon_xinmo_dan_tribulasi_batin.md | Hub + Stable |
| SYS-004 | akar_spiritual_spiritual_roots_talent_dan_aptitude.md | Hub + Stable |
| SYS-005 | physique_constitution_special_bodies_dan_bloodline_bodies.md | Stable |
| SYS-006 | teknik_manual_scriptures_arts_dan_inheritance_system.md | Hub + Stable |
| SYS-007 | qi_deviation_injury_poison_curse_backlash_dan_contamination.md | Hub + Stable |
| SYS-008 | lifespan_longevity_rejuvenation_dan_model_keabadian.md | Hub + Stable |
| SYS-009 | contracts_oaths_geasa_dan_keterikatan_kosmik.md | Stable |
| SYS-010 | moralitas_heavenly_dao_heartless_vs_humane_dao.md | Bridge + Stable |
| SYS-011 | seclusion_retreat_time_skip_dan_tempo_pertumbuhan.md | Bridge + Stable |
| SYS-012 | rank_grading_quality_systems_dan_hierarki_objek.md | Stable |
| SYS-013 | system_game_cultivation_panels_missions_dan_programmed_progression.md | Stable |

### 12.5 PATH — Jalur dan Spesialisasi

| ID | Judul | Status |
|---|---|---|
| PATH-001 | dao_path_jalan_kultivasi_dan_spesialisasi_filosofis.md | Hub + Stable |
| PATH-002 | body_cultivation.md | Stable |
| PATH-003 | sword_cultivation.md | Stable |
| PATH-004 | alchemy_pills_elixirs_dan_cauldron_path.md | Stable |
| PATH-005 | talisman_runes_seals_arrays_dan_formation_path.md | Stable |
| PATH-006 | beast_taming_bloodline_dan_companion_path.md | Stable |
| PATH-007 | soul_dream_illusion_mind_dan_spirit_path.md | Stable |
| PATH-008 | ghost_corpse_demonic_heterodox_dan_taboo_paths.md | Stable |
| PATH-009 | faith_merit_divinity_bureaucratic_dan_incense_paths.md | Stable |
| PATH-010 | dual_cultivation_yin_yang_union_dan_resonansi_pasangan.md | Stable |
| PATH-011 | poison_medical_healing_life_death_dan_restorative_paths.md | Stable |
| PATH-012 | esoteric_art_paths_overview_music_sound_calligraphy_painting_cooking.md | Satellite + Stable |
| PATH-013 | divination_astrology_stars_prophecy_dan_fate_reading_paths.md | Stable |
| PATH-014 | space_time_void_dan_travel_paths.md | Stable |
| PATH-015 | mundane_slow_life_farmer_gardener_merchant_scholar_paths.md | Stable |

### 12.6 WORLD — Masyarakat, Budaya, dan Kosmologi Terapan

| ID | Judul | Status |
|---|---|---|
| WORLD-001 | kosmologi_realm_dan_struktur_alam_semesta.md | Hub + Stable |
| WORLD-002 | spirit_ecology_veins_blessed_lands_secret_realms_dan_forbidden_zones.md | Hub + Stable |
| WORLD-003 | sekte_klan_dinasti_kota_kultivator_dan_struktur_sosial.md | Hub + Stable |
| WORLD-004 | ekonomi_resource_treasures_dan_pasaran_kultivasi.md | Hub + Stable |
| WORLD-005 | heavenly_court_underworld_reincarnation_dan_birokrasi_kosmik.md | Hub + Stable |
| WORLD-006 | perang_duel_siege_beast_tide_dan_skala_konflik_cultivation.md | Stable |
| WORLD-007 | agama_terorganisir_temple_orders_pilgrimage_dan_institusi_suci.md | Stable |
| WORLD-008 | ritual_upacara_inisiasi_pemakaman_sumpah_dan_praktik_sakral.md | Stable |
| WORLD-009 | budaya_harian_etiket_festival_hukum_adat_dan_sopan_santun_kultivator.md | Stable |
| WORLD-010 | keluarga_pernikahan_reproduksi_hereditas_dan_politik_bloodline.md | Stable |
| WORLD-011 | gender_dynamics_female_protagonists_dan_subversi_tropes.md | Bridge + Stable |
| WORLD-012 | ruins_tombs_grotto_heavens_trials_dan_ancient_inheritances.md | Stable |
| WORLD-013 | transportasi_teleportasi_flying_swords_ships_dan_infrastruktur.md | Stable |
| WORLD-014 | arsitektur_fengshui_spatial_design_dan_geografi_sakral_terbangun.md | Stable |
| WORLD-015 | estetika_sensory_design_dan_visualisasi_qi_realm_beast_artefak.md | Bridge + Stable |
| WORLD-016 | psikologi_kultivator_jangka_panjang_memori_kesepian_dan_dehumanisasi.md | Bridge + Stable |
| WORLD-017 | literasi_teks_prasasti_jade_slip_dan_transmisi_pengetahuan.md | Bridge + Stable |
| WORLD-018 | hukum_kriminalitas_punishment_dan_ketertiban_dalam_dunia_kultivasi.md | Stable |

### 12.7 ENTITY — Makhluk, Resource, Artefak, Profesi

| ID | Judul | Status |
|---|---|---|
| ENT-001 | bestiary_sacred_beasts_dan_mythic_creatures.md | Stable |
| ENT-002 | bestiary_demonic_chaotic_taboo_dan_apocalyptic_creatures.md | Stable |
| ENT-003 | bestiary_ghosts_spirits_undead_yokai_like_entities_dan_soul_beings.md | Stable |
| ENT-004 | tumbuhan_kultivasi_herbs_elixirs_spiritual_flora_dan_ekologi_obat.md | Hub + Stable |
| ENT-005 | materials_ores_metals_beast_cores_fires_waters_lightning_void_resources.md | Hub + Stable |
| ENT-006 | senjata_mitos_swords_spears_bows_staves_dan_relik_tempur.md | Stable |
| ENT-007 | artefak_fungsional_non_senjata_storage_communication_array_tools.md | Stable |
| ENT-008 | cauldrons_mirrors_seals_lamps_banners_pagodas_dan_symbolic_items.md | Stable |
| ENT-009 | profesi_khusus_alchemist_smith_refiner_inscriber_healer_diviner_breeder.md | Bridge + Stable |
| ENT-010 | mounts_pets_beast_ecologies_dan_status_symbols.md | Stable |

### 12.8 NARRATIVE — Struktur Cerita dan Tropes

| ID | Judul | Status |
|---|---|---|
| NARR-001 | tropes_khas_immortal_cultivation.md | Hub + Stable |
| NARR-002 | narrative_structure_pacing_dan_arc_cultivation_fiction.md | Hub + Stable |
| NARR-003 | character_progression_vs_power_progression.md | Stable |
| NARR-004 | exposition_lore_delivery_info_dump_management_dan_reveal_timing.md | Stable |
| NARR-005 | power_creep_escalation_dan_menjaga_ketegangan.md | Stable |
| NARR-006 | protagonist_archetypes_young_master_mentor_old_monster_dan_rival_models.md | Stable |
| NARR-007 | antagonist_archetypes_dan_konflik_struktural.md | Stable |
| NARR-008 | romance_harem_companions_sworn_bonds_dan_relational_structures.md | Stable |
| NARR-009 | comedy_meta_irony_slapface_dan_tonal_variation.md | Stable |
| NARR-010 | horror_tragedy_body_horror_dan_cosmic_dread_dalam_cultivation.md | Stable |
| NARR-011 | cultivation_as_detective_political_thriller_survival_dan_hybrid_narratives.md | Stable |
| NARR-012 | pov_voice_style_register_dan_diksi_cultivation_fiction.md | Stable |
| NARR-013 | serialisasi_update_rhythm_dan_bentuk_webnovel_cultivation.md | Bridge + Stable |

### 12.9 COMPARATIVE — Analisis Perbandingan

| ID | Judul | Status |
|---|---|---|
| COMP-001 | metodologi_perbandingan_subgenre_karya_dan_model.md | Hub + Stable |
| COMP-002 | perbandingan_sistem_qi_antar_subgenre.md | Stable |
| COMP-003 | perbandingan_model_dunia_cultivation.md | Stable |
| COMP-004 | perbandingan_jalur_kekuatan_antar_karya.md | Stable |
| COMP-005 | perbandingan_model_realm_breakthrough_dan_progression.md | Stable |
| COMP-006 | perbandingan_tribulation_heart_demon_dan_harga_kekuatan.md | Stable |
| COMP-007 | perbandingan_spiritual_roots_physiques_dan_model_bakat.md | Stable |
| COMP-008 | perbandingan_sekte_klan_birokrasi_dan_institusi_kekuatan.md | Stable |
| COMP-009 | perbandingan_nada_klasik_dark_comedic_romance_urban_scifi_system.md | Stable |
| COMP-010 | studi_kasus_karya_raksasa_genre.md | Stable |
| COMP-011 | matriks_karya_benchmark_dan_pemetaan_pengaruh.md | Living |

### 12.10 MARKET — Pasar, Platform, dan Industri

| ID | Judul | Status |
|---|---|---|
| MARKET-001 | timeline_novel_dan_komik_cultivation_paling_populer_per_tahun.md | Snapshot |
| MARKET-002 | ranking_mingguan_bulanan_tahunan_dan_cara_membacanya.md | Living |
| MARKET-003 | kanon_karya_cultivation_paling_berpengaruh.md | Hub + Living |
| MARKET-004 | ekosistem_platform_tiongkok_qidian_zongheng_fanqie_tencent_bilibili_kuaikan_dan_lainnya.md | Living |
| MARKET-005 | platform_internasional_dan_ekosistem_terjemahan_cultivation.md | Living |
| MARKET-006 | adaptation_pipeline_novel_manhua_donghua_drama_game_audio_merchandise.md | Living |
| MARKET-007 | penulis_berpengaruh_dan_gaya_sekolah_mereka.md | Living |
| MARKET-008 | fandom_komentar_voting_meme_culture_dan_budaya_pembaca.md | Living |
| MARKET-009 | ip_value_penghargaan_influence_lists_dan_umur_panjang_kanon.md | Living |
| MARKET-010 | resepsi_domestik_vs_taiwan_hongkong_vs_sea_vs_inggris_vs_jepang_korea.md | Living |
| MARKET-011 | trending_vs_fondasional_vs_legendaris_dalam_ekologi_karya.md | Living |
| MARKET-012 | snapshot_tahunan_pasar_cultivation_yyyy.md | Snapshot |
| MARKET-013 | regulasi_sensor_dan_batasan_industri_yang_membentuk_genre.md | Living |
| MARKET-014 | ekonomi_produksi_penulis_webnovel_cultivation.md | Living |

### 12.11 TOOLKIT — Creator Toolkit

| ID | Judul | Status |
|---|---|---|
| TOOL-001 | template_worldbuilding_cultivation_original.md | Hub + Stable |
| TOOL-002 | template_membuat_sistem_qi_original.md | Stable |
| TOOL-003 | template_membuat_realm_breakthrough_dan_tribulation_original.md | Stable |
| TOOL-004 | template_membuat_dao_path_dan_spesialisasi_original.md | Stable |
| TOOL-005 | template_membuat_sekte_klan_dan_institusi_kekuatan_original.md | Stable |
| TOOL-006 | template_membuat_bestiary_flora_resource_dan_artefak_original.md | Stable |
| TOOL-007 | template_membuat_kosmologi_dan_struktur_alam_original.md | Stable |
| TOOL-008 | template_membuat_ekonomi_politik_dan_hukum_kultivasi_original.md | Stable |
| TOOL-009 | template_membuat_narrative_arc_pacing_dan_serial_structure.md | Stable |
| TOOL-010 | anti_klise_guide_dan_cara_menyegarkan_genre.md | Stable |
| TOOL-011 | reverse_engineering_karya_dan_case_studies_worldbuilding_original.md | Stable |
| TOOL-012 | panduan_menulis_cultivation_fiction_berbasis_riset.md | Stable |

---

## 13. Register Hub Files Inti

Hub files inti yang berfungsi sebagai pusat gravitasi proyek:

- META-001
- META-002
- META-003
- META-004
- META-005
- META-007
- META-008
- META-009
- FOUND-001
- FOUND-003
- FOUND-008
- CORE-001
- CORE-003
- CORE-004
- SYS-001
- SYS-002
- SYS-003
- SYS-004
- SYS-006
- SYS-008
- PATH-001
- WORLD-001
- WORLD-002
- WORLD-003
- WORLD-004
- WORLD-005
- NARR-001
- NARR-002
- COMP-001
- MARKET-003
- TOOL-001

---

## 14. Minimum Viable Archive (MVA)

Subset minimum yang harus tetap bernilai mandiri apabila ekspansi penuh belum tercapai:

- META-001 s.d. META-005
- FOUND-001, FOUND-003, FOUND-008
- CORE-001, CORE-003, CORE-004
- SYS-001, SYS-002, SYS-003, SYS-004, SYS-006
- PATH-001
- WORLD-001, WORLD-003, WORLD-004
- NARR-001, NARR-002
- TOOL-001

Fungsi MVA:
- produk minimum yang tetap utuh;
- fondasi untuk ekspansi berikutnya;
- titik aman apabila proyek berhenti sementara.

---

## 15. Milestone Proyek

| Milestone | Kriteria |
|---|---|
| Milestone 1 — Governance Ready | META-001 s.d. META-005 selesai; korpus benchmark dan standar istilah terkunci |
| Milestone 2 — Ontology Ready | FOUND-001, FOUND-003, FOUND-008, CORE-001, CORE-003, CORE-004, SYS-001 s.d. SYS-004 selesai min. Level 2 |
| Milestone 3 — World Model Ready | WORLD-001 s.d. WORLD-005, PATH-001, SYS-006, SYS-008 selesai min. Level 2 |
| Milestone 4 — Writer-Usable Archive | NARR-001, NARR-002, TOOL-001, TOOL-002, TOOL-003 selesai min. Level 2 |
| Milestone 5 — Comparative & Market Expansion | COMP-001, COMP-002, COMP-003, COMP-009, MARKET-002, MARKET-003, MARKET-004, MARKET-006 tersedia |
| Milestone 6 — Full Expansion | file satelit, market living files, dan toolkit lanjutan berkembang stabil |

---

## 16. Urutan Implementasi Prioritas

### Fase A — Governance
1. META-001
2. META-002
3. META-003
4. META-004
5. META-005
6. META-007
7. META-008
8. META-009

### Fase B — Kamus Ontologis
9. FOUND-001
10. FOUND-003
11. FOUND-008
12. CORE-001
13. CORE-002
14. CORE-003
15. CORE-004
16. CORE-005

### Fase C — Mesin Cultivation
17. SYS-001
18. SYS-002
19. SYS-003
20. SYS-004
21. SYS-006
22. SYS-007
23. SYS-008
24. PATH-001

### Fase D — Model Dunia
25. WORLD-001
26. WORLD-002
27. WORLD-003
28. WORLD-004
29. WORLD-005
30. WORLD-015
31. WORLD-016
32. WORLD-017

### Fase E — Naratif dan Toolkit Dasar
33. NARR-001
34. NARR-002
35. NARR-005
36. TOOL-001
37. TOOL-002
38. TOOL-003
39. TOOL-010

### Fase F — Ekspansi Terkendali
- pengisian file satelit,
- file comparative lanjutan,
- living market files,
- bridge files tambahan,
- toolkit ekspansif.

---

## 17. Keputusan Desain yang Wajib Dikunci Sebelum Produksi File Inti

1. **Korpus benchmark**: 10–20 karya utama yang digunakan lintas file.
2. **Bahasa terminologi**: aturan bahasa primer, transliterasi, dan padanan istilah.
3. **Audiens arsip**: internal, kolaboratif, atau publik.
4. **Throughput realistis**: kapasitas jam per minggu dan target output per bulan.
5. **File pilot**: satu file uji template penuh sebelum produksi file Level 3 skala besar.

---

## 18. Risiko Utama dan Mekanisme Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Overlap tinggi antardokumen | duplikasi, kebocoran scope | owner matrix di META-003 |
| Inflasi cakupan | proyek melambat atau mandek | milestone + MVA + throughput planning |
| Ketidakkonsistenan istilah | kualitas arsip turun | glosarium pusat + metodologi istilah |
| File Living tidak terawat | data pasar cepat basi | jadwal pembaruan periodik |
| Hub files terlalu lambat selesai | ekspansi kehilangan pusat | prioritas fase implementasi |
| Ketidakseimbangan kedalaman | arsip timpang | level target dan done criteria |

---

## 19. Penutup

Blueprint ini menetapkan bentuk V3.1 sebagai **dokumen induk eksekutif** untuk arsip riset cultivation yang bersifat modular, luas, dan jangka panjang.

Secara evolutif:
- V1 berfungsi sebagai daftar topik;
- V2 berfungsi sebagai arsitektur arsip;
- V3.1 berfungsi sebagai arsitektur arsip yang telah dilengkapi dengan governance, quality control, milestone, risk control, dan kerangka implementasi operasional.

Dengan konfigurasi tersebut, proyek dapat bergerak ke fase implementasi tanpa kehilangan kelengkapan konseptual dan tanpa mengorbankan disiplin dokumentasi.
