# Master Blueprint V3 — Rencana Topik Riset Terpisah Immortal Cultivation / Xianxia / Xiuzhen

Dokumen ini merupakan **revisi arsitektural V3** yang menyintesis temuan evaluatif paling kuat dari penelaahan versi sebelumnya. Fokus revisi mencakup:
- penguatan arsitektur konten dan pengendalian overlap,
- penguatan project governance, versioning, MVP, dan milestone,
- penguatan done criteria, template bertingkat, serta pemisahan domain dan peran file.

Arah strategis V3 ditetapkan sebagai berikut:
> **cakupan tetap luas dan diperluas secara sadar**, dengan pengendalian melalui sistem kerja, aturan status, owner concept, milestone, dan protokol implementasi.

---

# 1. APA YANG BERUBAH DARI V2 → V3

V3 melakukan 10 pembaruan besar:

1. **Sistem ID diubah ke format prefiks domain**, bukan hanya blok angka.
   - Contoh: `META-001`, `CORE-003`, `WORLD-012`
   - Tujuan: menghindari sesak numbering saat proyek berkembang.

2. **Label dipisah jadi dua dimensi resmi**:
   - **Domain**: META, FOUNDATION, CORE, SYSTEM, PATH, WORLD, ENTITY, NARRATIVE, COMPARATIVE, MARKET, TOOLKIT
   - **Peran/Status**: Hub, Satellite, Bridge, Stable, Living, Snapshot, Draft

3. **Ditambahkan tiga file governance baru**:
   - `META-007_protokol_revisi_verifikasi_dan_versioning.md`
   - `META-008_estimasi_effort_dan_throughput_planning.md`
   - `META-009_minimum_viable_archive_dan_milestone.md`

4. **Template file dipecah jadi bertingkat**:
   - Template penuh untuk Hub Files
   - Template ringkas untuk Satellite Files
   - Template data untuk Snapshot/Living Files

5. **Ditambahkan konsep “owner of concept”**.
   Setiap konsep besar harus punya file utama pemilik konsep; file lain hanya menyentuh dan merujuk.

6. **Ditambahkan done criteria per level**.
   Supaya file bisa benar-benar “selesai”, bukan berkembang tanpa akhir.

7. **Ditambahkan track pembaca dan track kerja**.
   Karena arsip ini terlalu besar untuk dibaca linear.

8. **Ditambahkan gap penting dari evaluator**:
   - temporal experience / time dilation / cosmic nostalgia
   - literasi, teks, jade slips, prasasti, transmisi pengetahuan
   - platform internasional dan ekosistem terjemahan
   - mundane / slow-life / merchant / scholar paths
   - antagonist archetypes & structural conflict
   - ekonomi produksi webnovel cultivation
   - system/game cultivation sebagai file sendiri

9. **Blok COMPARATIVE dirapikan**.
   Tidak hanya “perbandingan X”, tapi juga ada file metodologi perbandingan dan matriks pengaruh.

10. **Kanon dan pasar diperlakukan lebih jujur sebagai data bergerak**.
   Beberapa file yang sebelumnya terasa “tetap” kini diperlakukan sebagai Living File.

---

# 2. FILOSOFI V3

V3 dibangun di atas 8 prinsip:

1. **Lengkap lebih penting daripada ringkas**, tetapi kelengkapan harus dikelola.
2. **Tidak semua file setara**; ada file pusat dan file orbit.
3. **Setiap konsep besar punya pemilik utama**.
4. **Setiap file harus tahu batas dirinya**.
5. **Proyek besar butuh governance, bukan hanya inspirasi**.
6. **Pasar, ranking, dan IP perlu diperlakukan sebagai data hidup**.
7. **Kedalaman bertahap lebih realistis daripada langsung Level 3 semua**.
8. **Produk minimum harus tetap berguna walau proyek berhenti di tengah**.

---

# 3. SISTEM KLASIFIKASI RESMI V3

## 3.1 Domain Labels
- **META** → metodologi, indeks, glosarium, governance
- **FOUNDATION** → akar budaya, sejarah, filsafat, genre dasar
- **CORE** → ontologi, metafisika, hukum dasar cultivation
- **SYSTEM** → progresi, risiko, struktur kekuatan, aturan advancement
- **PATH** → jalur/disiplin/spesialisasi cultivation
- **WORLD** → masyarakat, institusi, budaya, geografi, kosmologi terapan
- **ENTITY** → flora, fauna, resource, senjata, artefak, profesi
- **NARRATIVE** → struktur cerita, tropes, pacing, karakter, tonalitas
- **COMPARATIVE** → perbandingan antar karya, subgenre, era, model sistem
- **MARKET** → platform, ranking, IP, fandom, resepsi, ekonomi industri
- **TOOLKIT** → template, panduan desain original, anti-klise, reverse engineering

## 3.2 Role Labels
- **Hub** → file pusat, sering dirujuk
- **Satellite** → file pendukung/topik khusus
- **Bridge** → file penghubung dua domain

## 3.3 Temporal Status Labels
- **Stable** → relatif final, revisi jarang
- **Living** → diperbarui berkala
- **Snapshot** → menangkap kondisi pada tanggal/periode tertentu
- **Draft** → masih tahap kerja

## 3.4 Aturan Kombinasi Status
- `Hub` / `Satellite` / `Bridge` = **sumbu fungsi**
- `Stable` / `Living` / `Snapshot` / `Draft` = **sumbu temporal**
- `Stable` dan `Living` **tidak boleh** dipakai bersamaan
- `Stable` dan `Snapshot` **tidak boleh** dipakai bersamaan
- `Living` dan `Snapshot` biasanya **tidak dipakai bersamaan**
- File boleh menjadi `Hub + Stable`, `Satellite + Living`, `Bridge + Draft`, dst.

---

# 4. TEMPLATE FILE V3

## 4.1 Template Penuh — untuk Hub Files
1. ID file
2. Judul file
3. Domain & role/status
4. Pertanyaan inti file ini
5. Mengapa topik ini penting
6. Batas file ini
7. Tidak membahas apa
8. Owner concept
9. Akar filosofis / historis / mitologis / genre
10. Terminologi penting
11. Variasi antar subgenre / antar karya
12. Fungsi dalam worldbuilding
13. Fungsi dalam sistem kekuatan
14. Implikasi naratif, sosial, psikologis
15. Trope umum
16. Klise umum yang harus dihindari
17. Peluang inovasi
18. Karya acuan
19. File terkait
20. Pertanyaan riset yang belum terjawab
21. Source policy singkat
22. Last updated / version

## 4.2 Template Ringkas — untuk Satellite Files
1. ID file
2. Judul file
3. Domain & status
4. Pertanyaan inti
5. Fokus file ini
6. Tidak membahas apa
7. Terminologi kunci
8. Owner concept
9. Karya acuan
10. File terkait
11. Last updated

## 4.3 Template Data — untuk Snapshot/Living Market Files
1. ID file
2. Periode data / tanggal snapshot
3. Pertanyaan inti
4. Metodologi pengumpulan data
5. Sumber utama
6. Metrik yang dipakai
7. Temuan utama
8. Perubahan dari snapshot sebelumnya
9. Keterbatasan data
10. File terkait

---

# 5. DONE CRITERIA PER LEVEL

## Level 1
- 1 draft lengkap
- 1 revisi
- minimal 3 sumber / 3 karya acuan
- batas file jelas
- cross-reference dasar ada

## Level 2
- 1 draft lengkap
- 2 revisi
- minimal 5 sumber / 5 karya acuan relevan
- owner concept jelas
- overlap sudah dicek terhadap file terkait
- contoh konkret dari beberapa karya/subgenre tersedia

## Level 3
- 1 draft lengkap
- 3 revisi
- minimal 8–12 sumber / 8+ karya acuan relevan
- cross-check lintas domain
- ada ringkasan sintesis dan pertanyaan terbuka
- siap dijadikan rujukan inti untuk file lain

---

# 6. SOURCE POLICY PER DOMAIN

- **FOUNDATION** → teks klasik, studi agama, sejarah budaya, mitologi, akademik
- **CORE / SYSTEM** → gabungan tradisi, karya primer, analisis genre, observasi sistematis
- **PATH / WORLD / ENTITY** → terutama korpus karya primer + kajian tematik
- **NARRATIVE** → karya primer, teori naratif populer, observasi struktur serial
- **COMPARATIVE** → korpus benchmark wajib + tabel perbandingan + sintesis
- **MARKET** → platform resmi, chart, laporan industri, artikel data, snapshot tanggal
- **TOOLKIT** → sintesis dari semua domain, bukan klaim sejarah murni

---

# 7. TRACK PEMBACA / READING TRACKS

## Track A — Worldbuilder / Penulis
`META-001 → META-002 → FOUND-001 → CORE-001 → CORE-003 → SYSTEM-001 → PATH-001 → WORLD-001 → NARR-001 → TOOL-001`

## Track B — Analis Genre
`META-001 → FOUND-001 → FOUND-003 → COMP-001 → COMP-002 → COMP-008 → MARKET-001 → MARKET-003`

## Track C — Fondasi Budaya & Filosofis
`FOUND-001 → FOUND-002 → FOUND-003 → FOUND-004 → FOUND-005 → FOUND-006 → WORLD-007`

## Track D — Power System Deep Dive
`CORE-001 → CORE-002 → CORE-003 → CORE-004 → SYSTEM-001 → SYSTEM-002 → SYSTEM-003 → SYSTEM-004 → PATH-001`

## Track E — Jalur Cepat 10 File Inti
`META-001, META-002, META-003, META-004, FOUND-001, CORE-001, CORE-003, SYSTEM-001, PATH-001, WORLD-001`

---

# 8. DAFTAR FILE V3

## A. META / GOVERNANCE / REFERENCE

### META-001 `master_index_dan_status_proyek.md`
**Status:** Hub + Living
**Fokus:** indeks semua file, status, level, milestone, owner concept registry.

### META-002 `metodologi_korpus_dan_konvensi_riset.md`
**Status:** Hub + Stable
**Fokus:** ruang lingkup proyek, standar istilah, pembeda tradisi vs trope vs toolkit.

### META-003 `batas_scope_owner_matrix_dan_relasi_antar_file.md`
**Status:** Hub + Living
**Fokus:** file owner per konsep, matriks overlap, aturan rujukan, file yang hanya “menyentuh” topik.

### META-004 `korpus_benchmark_dan_alasan_pemilihan.md`
**Status:** Hub + Living
**Fokus:** 10–20 karya benchmark lintas era/subgenre.

### META-005 `glosarium_istilah_cultivation.md`
**Status:** Hub + Living
**Fokus:** istilah Mandarin–Inggris–Indonesia dan nuansanya.

### META-006 `bibliografi_peta_sumber_dan_klasifikasi_referensi.md`
**Status:** Hub + Living
**Fokus:** peta sumber primer, sekunder, platform, dan kajian.

### META-007 `protokol_revisi_verifikasi_dan_versioning.md`
**Status:** Hub + Stable
**Fokus:** validasi, review, perubahan versi, kapan file dianggap naik versi.

### META-008 `estimasi_effort_dan_throughput_planning.md`
**Status:** Hub + Living
**Fokus:** estimasi jam, ritme mingguan, throughput realistis.

### META-009 `minimum_viable_archive_dan_milestone.md`
**Status:** Hub + Stable
**Fokus:** subset 15–20 file yang harus jadi dulu, milestone fase proyek.

### META-010 `tagging_dependency_graph_dan_reading_map.md`
**Status:** Stable
**Fokus:** tag, dependency graph, peta baca.

### META-011 `indeks_contoh_karya_per_konsep.md`
**Status:** Living
**Fokus:** contoh karya terbaik per konsep/path/trope.

### META-012 `quickstart_pembaca_baru_dan_orientation_map.md`
**Status:** Stable
**Fokus:** entry point bagi pembaca baru/kolaborator.

---

## B. FOUNDATION — AKAR GENRE, FILSAFAT, DAN BUDAYA

### FOUND-001 `fondasi_genre_cultivation.md`
**Status:** Hub + Stable
**Fokus:** peta besar cultivation sebagai genre dan ekosistem.

### FOUND-002 `xianxia_wuxia_xiuzhen_xiuxian_xuanhuan_shenmo.md`
**Status:** Hub + Stable
**Fokus:** beda subgenre inti dan istilah payung.

### FOUND-003 `akar_daoisme_buddhisme_konfusianisme_dan_folk_religion.md`
**Status:** Hub + Stable
**Fokus:** akar filosofis dan religius.

### FOUND-004 `neidan_waidan_dan_alkimia_tubuh_tradisi_ke_fiksi.md`
**Status:** Stable
**Fokus:** transisi alkimia tradisional ke cultivation fiction.

### FOUND-005 `teks_klasik_mitologi_dan_mesin_imajinasi_genre.md`
**Status:** Stable
**Fokus:** teks klasik utama dan fungsi imajinatifnya.

### FOUND-006 `konsep_keabadian_transendensi_dan_xian_dalam_tradisi_tiongkok.md`
**Status:** Stable
**Fokus:** xian, transcendence, keabadian dalam tradisi.

### FOUND-007 `heaven_earth_human_triad_dan_kosmologi_dasar.md`
**Status:** Stable
**Fokus:** Heaven–Earth–Human sebagai kerangka dasar.

### FOUND-008 `bahasa_terjemahan_dan_masalah_terminologi_cultivation.md`
**Status:** Hub + Stable
**Fokus:** bagaimana menerjemahkan istilah tanpa merusak konsep.

### FOUND-009 `varian_lintas_budaya_murim_senjutsu_tu_tien_dan_hibrida_asia.md`
**Status:** Stable
**Fokus:** varian Asia Timur/Asia Tenggara yang relevan.

### FOUND-010 `sejarah_literatur_web_tiongkok_dan_lahirnya_cultivation_modern.md`
**Status:** Stable
**Fokus:** konteks kelahiran webnovel cultivation modern.

---

## C. CORE — ONTOLOGI DAN METAFISIKA DASAR

### CORE-001 `riset_qi_komprehensif.md`
**Status:** Hub + Stable
**Level target:** 3
**Fokus:** apa itu Qi dan bagaimana ia bekerja.

### CORE-002 `jing_qi_shen_dan_tiga_harta.md`
**Status:** Hub + Stable
**Fokus:** triad essence-energy-spirit.

### CORE-003 `dantian_meridian_acupoints_dan_sirkulasi_energi.md`
**Status:** Hub + Stable
**Fokus:** anatomi spiritual dan sirkulasi.

### CORE-004 `dao_sebagai_ontologi_hukum_kosmik_dan_enlightenment.md`
**Status:** Hub + Stable
**Level target:** 3
**Fokus:** struktur dan ontologi Dao.

### CORE-005 `yin_yang_wuxing_dan_logika_transformasi.md`
**Status:** Stable
**Fokus:** dinamika transformasi, bukan sekadar elemen.

### CORE-006 `dao_heart_true_meaning_true_essence_intent_dan_domain.md`
**Status:** Stable
**Fokus:** epistemologi dan internalisasi Dao.

### CORE-007 `nama_sejati_bahasa_suci_mantra_true_words_dan_runic_language.md`
**Status:** Stable
**Fokus:** bahasa sebagai kekuatan dan otoritas.

### CORE-008 `space_time_void_dan_hukum_dimensional.md`
**Status:** Stable
**Fokus:** ruang, waktu, kehampaan, portal, dimensi.

### CORE-009 `fate_destiny_mandate_dan_jalinan_nasib.md`
**Status:** Stable
**Fokus:** hal-hal yang “ditetapkan” secara kosmik.

### CORE-010 `luck_fortune_luck_stealing_dan_probabilitas_sakral.md`
**Status:** Stable
**Fokus:** keberuntungan yang bisa dimanipulasi/direbut.

### CORE-011 `karma_causality_dan_sebab_akibat_kosmik.md`
**Status:** Stable
**Fokus:** hukum sebab-akibat, pembalasan, jejak tindakan.

### CORE-012 `identity_soul_signature_memory_continuity_dan_personhood.md`
**Status:** Bridge + Stable
**Fokus:** identitas ontologis kultivator setelah transformasi, klon, possession, reinkarnasi.

### CORE-013 `temporal_experience_time_dilation_dan_nostalgia_kosmik.md`
**Status:** Bridge + Stable
**Fokus:** pengalaman waktu, kesenjangan temporal, nostalgia antar realm.

---

## D. SYSTEM — PROGRESI, RISIKO, DAN STRUKTUR KEKUATAN

### SYS-001 `realm_breakthrough_dan_struktur_kultivasi.md`
**Status:** Hub + Stable
**Level target:** 3

### SYS-002 `heavenly_tribulation_eksternal_dan_harga_kekuatan.md`
**Status:** Hub + Stable
**Fokus:** ujian eksternal dari langit.

### SYS-003 `heart_demon_xinmo_dan_tribulasi_batin.md`
**Status:** Hub + Stable
**Fokus:** krisis internal, obsesi, retakan batin.

### SYS-004 `akar_spiritual_spiritual_roots_talent_dan_aptitude.md`
**Status:** Hub + Stable

### SYS-005 `physique_constitution_special_bodies_dan_bloodline_bodies.md`
**Status:** Stable

### SYS-006 `teknik_manual_scriptures_arts_dan_inheritance_system.md`
**Status:** Hub + Stable

### SYS-007 `qi_deviation_injury_poison_curse_backlash_dan_contamination.md`
**Status:** Hub + Stable

### SYS-008 `lifespan_longevity_rejuvenation_dan_model_keabadian.md`
**Status:** Hub + Stable

### SYS-009 `contracts_oaths_geasa_dan_keterikatan_kosmik.md`
**Status:** Stable

### SYS-010 `moralitas_heavenly_dao_heartless_vs_humane_dao.md`
**Status:** Bridge + Stable
**Fokus:** etika kosmik dan legitimasi moral cultivation.

### SYS-011 `seclusion_retreat_time_skip_dan_tempo_pertumbuhan.md`
**Status:** Bridge + Stable

### SYS-012 `rank_grading_quality_systems_dan_hierarki_objek.md`
**Status:** Stable

### SYS-013 `system_game_cultivation_panels_missions_dan_programmed_progression.md`
**Status:** Stable
**Fokus:** system cultivation sebagai arus besar modern.

---

## E. PATH — JALUR, DISIPLIN, DAN SPESIALISASI CULTIVATION

### PATH-001 `dao_path_jalan_kultivasi_dan_spesialisasi_filosofis.md`
**Status:** Hub + Stable

### PATH-002 `body_cultivation.md`
**Status:** Stable

### PATH-003 `sword_cultivation.md`
**Status:** Stable

### PATH-004 `alchemy_pills_elixirs_dan_cauldron_path.md`
**Status:** Stable

### PATH-005 `talisman_runes_seals_arrays_dan_formation_path.md`
**Status:** Stable

### PATH-006 `beast_taming_bloodline_dan_companion_path.md`
**Status:** Stable

### PATH-007 `soul_dream_illusion_mind_dan_spirit_path.md`
**Status:** Stable

### PATH-008 `ghost_corpse_demonic_heterodox_dan_taboo_paths.md`
**Status:** Stable

### PATH-009 `faith_merit_divinity_bureaucratic_dan_incense_paths.md`
**Status:** Stable

### PATH-010 `dual_cultivation_yin_yang_union_dan_resonansi_pasangan.md`
**Status:** Stable

### PATH-011 `poison_medical_healing_life_death_dan_restorative_paths.md`
**Status:** Stable

### PATH-012 `esoteric_art_paths_overview_music_sound_calligraphy_painting_cooking.md`
**Status:** Satellite + Stable
**Fokus:** overview jalur seni; bisa dipecah jika proyek berkembang.

### PATH-013 `divination_astrology_stars_prophecy_dan_fate_reading_paths.md`
**Status:** Stable

### PATH-014 `space_time_void_dan_travel_paths.md`
**Status:** Stable
**Fokus:** aplikasi cultivation sebagai spesialisasi, bukan hukum dasar.

### PATH-015 `mundane_slow_life_farmer_gardener_merchant_scholar_paths.md`
**Status:** Stable
**Fokus:** jalur non-combat, slow-life, scholar, dan produksi nilai non-tempur.

---

## F. WORLD — MASYARAKAT, BUDAYA, KOSMOLOGI TERAPAN, DAN KEHIDUPAN CULTIVATION

### WORLD-001 `kosmologi_realm_dan_struktur_alam_semesta.md`
**Status:** Hub + Stable

### WORLD-002 `spirit_ecology_veins_blessed_lands_secret_realms_dan_forbidden_zones.md`
**Status:** Hub + Stable

### WORLD-003 `sekte_klan_dinasti_kota_kultivator_dan_struktur_sosial.md`
**Status:** Hub + Stable

### WORLD-004 `ekonomi_resource_treasures_dan_pasaran_kultivasi.md`
**Status:** Hub + Stable

### WORLD-005 `heavenly_court_underworld_reincarnation_dan_birokrasi_kosmik.md`
**Status:** Hub + Stable

### WORLD-006 `perang_duel_siege_beast_tide_dan_skala_konflik_cultivation.md`
**Status:** Stable

### WORLD-007 `agama_terorganisir_temple_orders_pilgrimage_dan_institusi_suci.md`
**Status:** Stable

### WORLD-008 `ritual_upacara_inisiasi_pemakaman_sumpah_dan_praktik_sakral.md`
**Status:** Stable

### WORLD-009 `budaya_harian_etiket_festival_hukum_adat_dan_sopan_santun_kultivator.md`
**Status:** Stable

### WORLD-010 `keluarga_pernikahan_reproduksi_hereditas_dan_politik_bloodline.md`
**Status:** Stable

### WORLD-011 `gender_dynamics_female_protagonists_dan_subversi_tropes.md`
**Status:** Bridge + Stable

### WORLD-012 `ruins_tombs_grotto_heavens_trials_dan_ancient_inheritances.md`
**Status:** Stable

### WORLD-013 `transportasi_teleportasi_flying_swords_ships_dan_infrastruktur.md`
**Status:** Stable

### WORLD-014 `arsitektur_fengshui_spatial_design_dan_geografi_sakral_terbangun.md`
**Status:** Stable
**Fokus:** tempat hidup, bukan formation atau ekologi.

### WORLD-015 `estetika_sensory_design_dan_visualisasi_qi_realm_beast_artefak.md`
**Status:** Bridge + Stable

### WORLD-016 `psikologi_kultivator_jangka_panjang_memori_kesepian_dan_dehumanisasi.md`
**Status:** Bridge + Stable

### WORLD-017 `literasi_teks_prasasti_jade_slip_dan_transmisi_pengetahuan.md`
**Status:** Bridge + Stable

### WORLD-018 `hukum_kriminalitas_punishment_dan_ketertiban_dalam_dunia_kultivasi.md`
**Status:** Stable

---

## G. ENTITY — MAKHLUK, FLORA, RESOURCE, ARTEFAK, PROFESI

### ENT-001 `bestiary_sacred_beasts_dan_mythic_creatures.md`
**Status:** Stable

### ENT-002 `bestiary_demonic_chaotic_taboo_dan_apocalyptic_creatures.md`
**Status:** Stable

### ENT-003 `bestiary_ghosts_spirits_undead_yokai_like_entities_dan_soul_beings.md`
**Status:** Stable

### ENT-004 `tumbuhan_kultivasi_herbs_elixirs_spiritual_flora_dan_ekologi_obat.md`
**Status:** Hub + Stable

### ENT-005 `materials_ores_metals_beast_cores_fires_waters_lightning_void_resources.md`
**Status:** Hub + Stable

### ENT-006 `senjata_mitos_swords_spears_bows_staves_dan_relik_tempur.md`
**Status:** Stable

### ENT-007 `artefak_fungsional_non_senjata_storage_communication_array_tools.md`
**Status:** Stable

### ENT-008 `cauldrons_mirrors_seals_lamps_banners_pagodas_dan_symbolic_items.md`
**Status:** Stable

### ENT-009 `profesi_khusus_alchemist_smith_refiner_inscriber_healer_diviner_breeder.md`
**Status:** Bridge + Stable

### ENT-010 `mounts_pets_beast_ecologies_dan_status_symbols.md`
**Status:** Stable

---

## H. NARRATIVE — TEKNIK CERITA, TROPE, DAN DRAMATURGI CULTIVATION

### NARR-001 `tropes_khas_immortal_cultivation.md`
**Status:** Hub + Stable

### NARR-002 `narrative_structure_pacing_dan_arc_cultivation_fiction.md`
**Status:** Hub + Stable

### NARR-003 `character_progression_vs_power_progression.md`
**Status:** Stable

### NARR-004 `exposition_lore_delivery_info_dump_management_dan_reveal_timing.md`
**Status:** Stable

### NARR-005 `power_creep_escalation_dan_menjaga_ketegangan.md`
**Status:** Stable

### NARR-006 `protagonist_archetypes_young_master_mentor_old_monster_dan_rival_models.md`
**Status:** Stable

### NARR-007 `antagonist_archetypes_dan_konflik_struktural.md`
**Status:** Stable

### NARR-008 `romance_harem_companions_sworn_bonds_dan_relational_structures.md`
**Status:** Stable

### NARR-009 `comedy_meta_irony_slapface_dan_tonal_variation.md`
**Status:** Stable

### NARR-010 `horror_tragedy_body_horror_dan_cosmic_dread_dalam_cultivation.md`
**Status:** Stable

### NARR-011 `cultivation_as_detective_political_thriller_survival_dan_hybrid_narratives.md`
**Status:** Stable

### NARR-012 `pov_voice_style_register_dan_diksi_cultivation_fiction.md`
**Status:** Stable

### NARR-013 `serialisasi_update_rhythm_dan_bentuk_webnovel_cultivation.md`
**Status:** Bridge + Stable
**Fokus:** bagaimana format serial membentuk struktur cerita cultivation.

---

## I. COMPARATIVE — PERBANDINGAN ANTAR SUBGENRE, KARYA, DAN MODEL

### COMP-001 `metodologi_perbandingan_subgenre_karya_dan_model.md`
**Status:** Hub + Stable

### COMP-002 `perbandingan_sistem_qi_antar_subgenre.md`
**Status:** Stable

### COMP-003 `perbandingan_model_dunia_cultivation.md`
**Status:** Stable

### COMP-004 `perbandingan_jalur_kekuatan_antar_karya.md`
**Status:** Stable

### COMP-005 `perbandingan_model_realm_breakthrough_dan_progression.md`
**Status:** Stable

### COMP-006 `perbandingan_tribulation_heart_demon_dan_harga_kekuatan.md`
**Status:** Stable

### COMP-007 `perbandingan_spiritual_roots_physiques_dan_model_bakat.md`
**Status:** Stable

### COMP-008 `perbandingan_sekte_klan_birokrasi_dan_institusi_kekuatan.md`
**Status:** Stable

### COMP-009 `perbandingan_nada_klasik_dark_comedic_romance_urban_scifi_system.md`
**Status:** Stable

### COMP-010 `studi_kasus_karya_raksasa_genre.md`
**Status:** Stable

### COMP-011 `matriks_karya_benchmark_dan_pemetaan_pengaruh.md`
**Status:** Living

---

## J. MARKET — PLATFORM, KANON, IP, FANDOM, INDUSTRI

### MARKET-001 `timeline_novel_dan_komik_cultivation_paling_populer_per_tahun.md`
**Status:** Snapshot

### MARKET-002 `ranking_mingguan_bulanan_tahunan_dan_cara_membacanya.md`
**Status:** Living

### MARKET-003 `kanon_karya_cultivation_paling_berpengaruh.md`
**Status:** Hub + Living
**Catatan:** kanon dianggap berubah dan harus direvisi berkala.

### MARKET-004 `ekosistem_platform_tiongkok_qidian_zongheng_fanqie_tencent_bilibili_kuaikan_dan_lainnya.md`
**Status:** Living

### MARKET-005 `platform_internasional_dan_ekosistem_terjemahan_cultivation.md`
**Status:** Living

### MARKET-006 `adaptation_pipeline_novel_manhua_donghua_drama_game_audio_merchandise.md`
**Status:** Living

### MARKET-007 `penulis_berpengaruh_dan_gaya_sekolah_mereka.md`
**Status:** Living

### MARKET-008 `fandom_komentar_voting_meme_culture_dan_budaya_pembaca.md`
**Status:** Living

### MARKET-009 `ip_value_penghargaan_influence_lists_dan_umur_panjang_kanon.md`
**Status:** Living

### MARKET-010 `resepsi_domestik_vs_taiwan_hongkong_vs_sea_vs_inggris_vs_jepang_korea.md`
**Status:** Living

### MARKET-011 `trending_vs_fondasional_vs_legendaris_dalam_ekologi_karya.md`
**Status:** Living

### MARKET-012 `snapshot_tahunan_pasar_cultivation_yyyy.md`
**Status:** Snapshot

### MARKET-013 `regulasi_sensor_dan_batasan_industri_yang_membentuk_genre.md`
**Status:** Living

### MARKET-014 `ekonomi_produksi_penulis_webnovel_cultivation.md`
**Status:** Living
**Fokus:** kontrak, update rate, insentif panjang, monetisasi serialisasi.

---

## K. TOOLKIT — DESAIN ORIGINAL DAN PANDUAN PRAKTIS

### TOOL-001 `template_worldbuilding_cultivation_original.md`
**Status:** Hub + Stable

### TOOL-002 `template_membuat_sistem_qi_original.md`
**Status:** Stable

### TOOL-003 `template_membuat_realm_breakthrough_dan_tribulation_original.md`
**Status:** Stable

### TOOL-004 `template_membuat_dao_path_dan_spesialisasi_original.md`
**Status:** Stable

### TOOL-005 `template_membuat_sekte_klan_dan_institusi_kekuatan_original.md`
**Status:** Stable

### TOOL-006 `template_membuat_bestiary_flora_resource_dan_artefak_original.md`
**Status:** Stable

### TOOL-007 `template_membuat_kosmologi_dan_struktur_alam_original.md`
**Status:** Stable

### TOOL-008 `template_membuat_ekonomi_politik_dan_hukum_kultivasi_original.md`
**Status:** Stable

### TOOL-009 `template_membuat_narrative_arc_pacing_dan_serial_structure.md`
**Status:** Stable

### TOOL-010 `anti_klise_guide_dan_cara_menyegarkan_genre.md`
**Status:** Stable

### TOOL-011 `reverse_engineering_karya_dan_case_studies_worldbuilding_original.md`
**Status:** Stable

### TOOL-012 `panduan_menulis_cultivation_fiction_berbasis_riset.md`
**Status:** Stable

---

# 9. DAFTAR HUB FILE INTI (TULANG PUNGGUNG V3)

Ini adalah pusat gravitasi proyek:

1. META-001
2. META-002
3. META-003
4. META-004
5. META-005
6. META-007
7. META-008
8. META-009
9. FOUND-001
10. FOUND-003
11. FOUND-008
12. CORE-001
13. CORE-003
14. CORE-004
15. SYS-001
16. SYS-002
17. SYS-003
18. SYS-004
19. SYS-006
20. SYS-008
21. PATH-001
22. WORLD-001
23. WORLD-002
24. WORLD-003
25. WORLD-004
26. WORLD-005
27. NARR-001
28. NARR-002
29. COMP-001
30. MARKET-003
31. TOOL-001

---

# 10. MINIMUM VIABLE ARCHIVE (MVA)

Dalam skenario penghentian proyek sebelum ekspansi penuh, subset berikut harus tetap berdiri sebagai produk utuh:

- META-001 sampai META-005
- FOUND-001, FOUND-003, FOUND-008
- CORE-001, CORE-003, CORE-004
- SYS-001, SYS-002, SYS-003, SYS-004, SYS-006
- PATH-001
- WORLD-001, WORLD-003, WORLD-004
- NARR-001, NARR-002
- TOOL-001

Subset ini berfungsi sebagai produk minimum yang tetap memadai bagi:
- penulis,
- worldbuilder,
- pembaca yang memerlukan pemahaman struktural cultivation.

---

# 11. MILESTONE PROYEK V3

## Milestone 1 — Governance Ready
Selesai jika:
- META-001 s.d. META-005 jadi
- korpus benchmark terkunci
- standar istilah terkunci
- dependency map awal jadi

## Milestone 2 — Ontology Ready
Selesai jika:
- FOUND-001, FOUND-003, FOUND-008
- CORE-001, CORE-003, CORE-004
- SYS-001, SYS-002, SYS-003, SYS-004
selesai minimal Level 2

## Milestone 3 — World Model Ready
Selesai jika:
- WORLD-001 sampai WORLD-005
- PATH-001
- SYS-006, SYS-008
selesai minimal Level 2

## Milestone 4 — Writer-Usable Archive
Selesai jika:
- NARR-001, NARR-002
- TOOL-001, TOOL-002, TOOL-003
selesai minimal Level 2

## Milestone 5 — Comparative & Market Expansion
Selesai jika:
- COMP-001, COMP-002, COMP-003, COMP-009
- MARKET-002, MARKET-003, MARKET-004, MARKET-006
jadi

## Milestone 6 — Full Expansion
Fase jangka panjang: isi satelit, update living files, dan memperluas toolkit.

---

# 12. URUTAN IMPLEMENTASI PRIORITAS V3

## Fase A — Governance Dulu
1. META-001
2. META-002
3. META-003
4. META-004
5. META-005
6. META-007
7. META-008
8. META-009

## Fase B — Bangun Kamus Ontologis
9. FOUND-001
10. FOUND-003
11. FOUND-008
12. CORE-001
13. CORE-002
14. CORE-003
15. CORE-004
16. CORE-005

## Fase C — Bangun Mesin Cultivation
17. SYS-001
18. SYS-002
19. SYS-003
20. SYS-004
21. SYS-006
22. SYS-007
23. SYS-008
24. PATH-001

## Fase D — Bangun Dunia
25. WORLD-001
26. WORLD-002
27. WORLD-003
28. WORLD-004
29. WORLD-005
30. WORLD-015
31. WORLD-016
32. WORLD-017

## Fase E — Naratif dan Toolkit Dasar
33. NARR-001
34. NARR-002
35. NARR-005
36. TOOL-001
37. TOOL-002
38. TOOL-003
39. TOOL-010

## Fase F — Ekspansi Sadar
Isi satelit, comparative, market, update living files, dan file-file spesialis.

---

# 13. KEPUTUSAN DESAIN YANG HARUS DIKUNCI SEBELUM PENULISAN FILE INTI

1. **Korpus benchmark**: penetapan 10–20 karya utama yang akan dipakai sebagai rujukan lintas file.
2. **Bahasa terminologi**: penetapan bahasa primer, format transliterasi, dan aturan padanan istilah.
3. **Audiens arsip**: penetapan orientasi dokumen untuk penggunaan internal, kolaboratif, atau publik.
4. **Throughput realistis**: penetapan kapasitas kerja mingguan dan target produksi file bulanan.
5. **File pilot**: penetapan satu file uji template penuh; kandidat awal yang disarankan ialah `SYS-004` atau `CORE-001` pada Level 2.

---

# 14. KESIMPULAN V3

V3 tidak dirancang untuk memperkecil cakupan. V3 dirancang untuk:
- **memperluas cakupan secara terkendali**,
- **meningkatkan sistematika internal**,
- **memperkuat kesiapan pengembangan jangka panjang**, dan
- **menetapkan governance, milestone, serta disiplin revisi sebagai bagian inti desain arsip**.

Ringkasan evolusi dokumen:
> **V1 = daftar topik**
>
> **V2 = arsitektur arsip**
>
> **V3 = arsitektur arsip + governance proyek + jalur implementasi operasional**

Dengan konfigurasi tersebut, V3 menempati bentuk yang paling dekat dengan **ensiklopedia modular cultivation** yang dapat berkembang tanpa cepat runtuh akibat overlap, inflasi scope, atau ketiadaan tata kelola.

---

# 15. URUTAN IMPLEMENTASI PASCA-V3

Urutan implementasi yang direkomendasikan adalah sebagai berikut:

1. menyusun `META-001_master_index_dan_status_proyek.md`;
2. menyusun `META-002_metodologi_korpus_dan_konvensi_riset.md`;
3. menyusun `META-003_batas_scope_owner_matrix_dan_relasi_antar_file.md`;
4. menyusun `META-004_korpus_benchmark_dan_alasan_pemilihan.md`;
5. menyusun `META-008_estimasi_effort_dan_throughput_planning.md`;
6. menguji template melalui satu file pilot Level 2;
7. setelah fondasi governance tervalidasi, memulai `CORE-001_riset_qi_komprehensif.md`.
