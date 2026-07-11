import '../daoji_text_key.dart';
import '../daoji_vocabulary_level.dart';

/// Partial Daoji ID registry: thinking_canvas_id.
const Map<DaojiVocabularyLevel, Map<DaojiTextKey, String>> daojiThinkingCanvasTextsId = {
  DaojiVocabularyLevel.mortal: {
    DaojiTextKey.thinkingCanvasTitle: 'Thinking Canvas',
    DaojiTextKey.thinkingCanvasHistory: 'Riwayat Sesi',
    DaojiTextKey.thinkingCanvasSessionHistoryTitle: 'Riwayat Thinking Canvas',
    DaojiTextKey.thinkingCanvasOpenMethodCatalog: 'Buka Katalog Metode',
    DaojiTextKey.thinkingCanvasWorkspaceLabel: 'Workspace: {title}',
    DaojiTextKey.thinkingCanvasWorkspaceHint:
    'Tulis ide atau kerangka berpikir Anda di sini...',
    DaojiTextKey.thinkingCanvasSaveSessionTitle: 'Simpan Sesi?',
    DaojiTextKey.thinkingCanvasSaveSessionBody:
    'Anda memiliki konten yang belum disimpan ke riwayat. Apa yang ingin Anda lakukan?',
    DaojiTextKey.thinkingCanvasDiscard: 'Buang',
    DaojiTextKey.thinkingCanvasSaveAndFinish: 'Simpan & Selesai',
    DaojiTextKey.thinkingCanvasDraftSaved: 'Draf tersimpan',
    DaojiTextKey.thinkingCanvasQuickStart: 'Mulai Cepat',
    DaojiTextKey.thinkingCanvasRecentlyUsed: 'Terakhir Digunakan',
    DaojiTextKey.thinkingCanvasShowGuideAgain: 'Lihat Panduan Lagi',
    DaojiTextKey.thinkingCanvasDeleteAllHistory: 'Hapus Semua History?',
    DaojiTextKey.thinkingCanvasDeleteAllAction: 'Hapus Semua',
    DaojiTextKey.thinkingCanvasDeleteAllHistoryBody:
    'Semua sesi akan dihapus dari riwayat (bisa di-soft-delete di database).',
    DaojiTextKey.thinkingCanvasNoSessionsTitle: 'Belum Ada Sesi',
    DaojiTextKey.thinkingCanvasNoSessionsBody:
    'Semua sesi eksplorasi ide terstruktur Anda akan tercatat di sini.',
    DaojiTextKey.thinkingCanvasDeleteSession: 'Hapus Sesi?',
    DaojiTextKey.thinkingCanvasLoadingSession: 'Memuat sesi...',
    DaojiTextKey.thinkingCanvasMoodPrompt: 'Apa yang Anda rasakan saat ini?',
    DaojiTextKey.thinkingCanvasMoodPromptSubtitle:
    'Pilih suasana hati untuk rekomendasi metode',
    DaojiTextKey.thinkingCanvasRecommendations: 'Rekomendasi untuk Anda',
    DaojiTextKey.methodPickerTitle: 'Pilih Metode Berpikir',
    DaojiTextKey.mindMapEditorTitle: 'Mind Map Editor',
    DaojiTextKey.mindMapUndoTooltip: 'Batalkan',
    DaojiTextKey.mindMapRecenterTooltip: 'Pusatkan',
    DaojiTextKey.mindMapAddBranchTooltip: 'Tambah Cabang',
    DaojiTextKey.mindMapEditTooltip: 'Edit',
    DaojiTextKey.mindMapDeleteTooltip: 'Hapus',
    DaojiTextKey.mindMapDefaultNodeText: 'Gagasan',
    DaojiTextKey.mindMapDefaultRootText: 'Topik Utama',
    DaojiTextKey.mindMapNewNodeText: 'Ide Baru',
    DaojiTextKey.mindMapNewChildNodeText: 'Sub-ide',
    DaojiTextKey.mindMapSaveButton: 'Simpan',
    DaojiTextKey.mindMapNewTopicButton: 'Topik Baru',

    // Weekly Pulse
  },
  DaojiVocabularyLevel.human: {

    DaojiTextKey.thinkingCanvasSaveSessionTitle: 'Simpan sesi ini?',
    DaojiTextKey.thinkingCanvasSaveSessionBody:
    'Masih ada catatan yang belum masuk riwayat. Simpan dulu, atau buang?',
    DaojiTextKey.thinkingCanvasDiscard: 'Buang',
    DaojiTextKey.thinkingCanvasSaveAndFinish: 'Simpan & Selesai',
    DaojiTextKey.thinkingCanvasDraftSaved: 'Draf tersimpan',
    DaojiTextKey.thinkingCanvasQuickStart: 'Mulai cepat',
    DaojiTextKey.thinkingCanvasRecentlyUsed: 'Baru dipakai',
    DaojiTextKey.thinkingCanvasShowGuideAgain: 'Lihat panduan lagi',
    DaojiTextKey.thinkingCanvasDeleteAllHistory: 'Hapus semua riwayat?',
    DaojiTextKey.thinkingCanvasDeleteAllAction: 'Hapus semua',
    DaojiTextKey.thinkingCanvasDeleteAllHistoryBody:
    'Semua sesi akan disembunyikan dari riwayat (soft-delete).',
    DaojiTextKey.thinkingCanvasNoSessionsTitle: 'Belum ada sesi',
    DaojiTextKey.thinkingCanvasNoSessionsBody:
    'Sesi berpikir terstruktur Anda akan muncul di sini.',
    DaojiTextKey.thinkingCanvasDeleteSession: 'Hapus sesi?',
    DaojiTextKey.thinkingCanvasLoadingSession: 'Memuat sesi...',
    DaojiTextKey.thinkingCanvasMoodPrompt: 'Bagaimana perasaan Anda sekarang?',
    DaojiTextKey.thinkingCanvasMoodPromptSubtitle:
    'Pilih mood untuk rekomendasi metode',
    DaojiTextKey.thinkingCanvasRecommendations: 'Rekomendasi untuk Anda',
  },
  DaojiVocabularyLevel.earth: {

    DaojiTextKey.thinkingCanvasSaveSessionTitle: 'Akar-kan sesi ini?',
    DaojiTextKey.thinkingCanvasSaveSessionBody:
    'Catatan ini belum mengakar di riwayat. Simpan, buang, atau lanjut menumbuhkan dulu?',
    DaojiTextKey.thinkingCanvasDiscard: 'Buang',
    DaojiTextKey.thinkingCanvasSaveAndFinish: 'Simpan & Selesai',
    DaojiTextKey.thinkingCanvasDraftSaved: 'Draf mengakar',
    DaojiTextKey.thinkingCanvasQuickStart: 'Tunas cepat',
    DaojiTextKey.thinkingCanvasRecentlyUsed: 'Baru dipelihara',
    DaojiTextKey.thinkingCanvasShowGuideAgain: 'Buka panduan lagi',
    DaojiTextKey.thinkingCanvasDeleteAllHistory: 'Cabut semua riwayat?',
    DaojiTextKey.thinkingCanvasDeleteAllAction: 'Cabut semua',
    DaojiTextKey.thinkingCanvasDeleteAllHistoryBody:
    'Semua sesi akan di-soft-delete dari tanah riwayat.',
    DaojiTextKey.thinkingCanvasNoSessionsTitle: 'Tanah masih kosong',
    DaojiTextKey.thinkingCanvasNoSessionsBody:
    'Sesi eksplorasi yang Anda tanam akan tercatat di sini.',
    DaojiTextKey.thinkingCanvasDeleteSession: 'Cabut sesi ini?',
    DaojiTextKey.thinkingCanvasLoadingSession: 'Menyirami sesi...',
    DaojiTextKey.thinkingCanvasMoodPrompt: 'Cuaca batin Anda hari ini?',
    DaojiTextKey.thinkingCanvasMoodPromptSubtitle:
    'Pilih suasana untuk rekomendasi metode',
    DaojiTextKey.thinkingCanvasRecommendations: 'Rekomendasi musim ini',
  },
  DaojiVocabularyLevel.heaven: {

    DaojiTextKey.thinkingCanvasSaveSessionTitle: 'Abadikan sesi ini?',
    DaojiTextKey.thinkingCanvasSaveSessionBody:
    'Masih ada jejak yang belum masuk scripture riwayat. Abadikan, buang, atau lanjut merenung?',
    DaojiTextKey.thinkingCanvasDiscard: 'Lepaskan',
    DaojiTextKey.thinkingCanvasSaveAndFinish: 'Abadikan & Selesai',
    DaojiTextKey.thinkingCanvasDraftSaved: 'Jejak draf tersimpan',
    DaojiTextKey.thinkingCanvasQuickStart: 'Pintu cepat',
    DaojiTextKey.thinkingCanvasRecentlyUsed: 'Baru dilalui',
    DaojiTextKey.thinkingCanvasShowGuideAgain: 'Buka scripture panduan',
    DaojiTextKey.thinkingCanvasDeleteAllHistory: 'Hapus seluruh scripture sesi?',
    DaojiTextKey.thinkingCanvasDeleteAllAction: 'Hapus arsip',
    DaojiTextKey.thinkingCanvasDeleteAllHistoryBody:
    'Semua sesi akan di-soft-delete dari arsip batin.',
    DaojiTextKey.thinkingCanvasNoSessionsTitle: 'Arsip masih hening',
    DaojiTextKey.thinkingCanvasNoSessionsBody:
    'Sesi kontemplasi terstruktur akan tercatat di sini.',
    DaojiTextKey.thinkingCanvasDeleteSession: 'Hapus sesi ini?',
    DaojiTextKey.thinkingCanvasLoadingSession: 'Membuka sesi...',
    DaojiTextKey.thinkingCanvasMoodPrompt: 'Getaran hati Anda saat ini?',
    DaojiTextKey.thinkingCanvasMoodPromptSubtitle:
    'Pilih resonansi untuk rekomendasi metode',
    DaojiTextKey.thinkingCanvasRecommendations: 'Resonansi yang disarankan',
    DaojiTextKey.thinkingCanvasTitle: 'Thinking Canvas',
    DaojiTextKey.thinkingCanvasHistory: 'Riwayat Sesi',
    DaojiTextKey.thinkingCanvasSessionHistoryTitle: 'Riwayat Thinking Canvas',
    DaojiTextKey.thinkingCanvasOpenMethodCatalog: 'Buka Katalog Metode',
    DaojiTextKey.thinkingCanvasWorkspaceLabel: 'Workspace: {title}',
    DaojiTextKey.thinkingCanvasWorkspaceHint:
    'Tulis ide atau kerangka berpikir Anda di sini...',
    DaojiTextKey.methodPickerTitle: 'Pilih Metode Berpikir',
  },
};

