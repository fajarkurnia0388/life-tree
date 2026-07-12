import '../daoji_text_key.dart';
import '../daoji_vocabulary_level.dart';

/// Partial Daoji ID registry: nav_id.
const Map<DaojiVocabularyLevel, Map<DaojiTextKey, String>> daojiNavTextsId = {
  DaojiVocabularyLevel.mortal: {
    DaojiTextKey.navHome: 'Home',
    DaojiTextKey.navJournal: 'Journal',
    DaojiTextKey.navReflection: 'Reflection',
    DaojiTextKey.navMarketplace: 'Pustaka Lokal',
    DaojiTextKey.navProfile: 'Profile',
    DaojiTextKey.navHomeHeaven: 'Sanctuary',
    DaojiTextKey.navJournalHeaven: 'Scripture',
    DaojiTextKey.navReflectionHeaven: 'Alchemy',
    DaojiTextKey.navMarketplaceHeaven: 'Arsip Lokal',
    DaojiTextKey.navProfileHeaven: 'Dao Heart',
  },
  DaojiVocabularyLevel.human: {
    DaojiTextKey.navHome: 'Home',
    DaojiTextKey.navJournal: 'Disciplines',
    DaojiTextKey.navReflection: 'Insight',
    DaojiTextKey.navMarketplace: 'Pustaka Lokal',
    DaojiTextKey.navProfile: 'Compass',
  },
  DaojiVocabularyLevel.earth: {
    DaojiTextKey.navHome: 'Training Hub',
    DaojiTextKey.navJournal: 'Qi Log',
    DaojiTextKey.navReflection: 'Refinement',
    DaojiTextKey.navMarketplace: 'Sutra Lokal',
    DaojiTextKey.navProfile: 'Compass',
  },
  DaojiVocabularyLevel.heaven: {
    DaojiTextKey.navHome: 'Void Sanctuary',
    DaojiTextKey.navJournal: 'Heart Scripture',
    DaojiTextKey.navReflection: 'Inner Alchemy',
    DaojiTextKey.navMarketplace: 'Arsip Lokal',
    DaojiTextKey.navProfile: 'Dao Heart',
  },
};

