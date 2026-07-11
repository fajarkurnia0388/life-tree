import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_level.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../dashboard/dashboard_view.dart';
import '../journal/journal_dashboard_tab.dart';
import '../reflection/reflection_dashboard_tab.dart';
import '../marketplace/marketplace_view.dart';
import '../profile/profile_dashboard_tab.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  final List<Widget> _tabs = const [
    DashboardView(),
    JournalDashboardTab(),
    ReflectionDashboardTab(),
    MarketplaceView(),
    ProfileDashboardTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    String navLabel(DaojiTextKey key) {
      if (vocabularyLevel == DaojiVocabularyLevel.heaven) {
        final heavenKey = switch (key) {
          DaojiTextKey.navHome => DaojiTextKey.navHomeHeaven,
          DaojiTextKey.navJournal => DaojiTextKey.navJournalHeaven,
          DaojiTextKey.navReflection => DaojiTextKey.navReflectionHeaven,
          DaojiTextKey.navMarketplace => DaojiTextKey.navMarketplaceHeaven,
          DaojiTextKey.navProfile => DaojiTextKey.navProfileHeaven,
          _ => key,
        };
        return DaojiText.resolve(heavenKey, vocabularyLevel);
      }
      return DaojiText.resolve(key, vocabularyLevel);
    }

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // Add haptic feedback on tab switch
          HapticFeedback.lightImpact();
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: navLabel(DaojiTextKey.navHome),
          ),
          NavigationDestination(
            icon: const Icon(Icons.book_outlined),
            selectedIcon: const Icon(Icons.book),
            label: navLabel(DaojiTextKey.navJournal),
          ),
          NavigationDestination(
            icon: const Icon(Icons.psychology_outlined),
            selectedIcon: const Icon(Icons.psychology),
            label: navLabel(DaojiTextKey.navReflection),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: navLabel(DaojiTextKey.navMarketplace),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: navLabel(DaojiTextKey.navProfile),
          ),
        ],
      ),
    );
  }
}
