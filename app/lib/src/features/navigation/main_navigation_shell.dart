import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
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

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // Add haptic feedback on tab switch
          HapticFeedback.lightImpact();
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: DaojiText.resolve(DaojiTextKey.navHome, vocabularyLevel),
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: DaojiText.resolve(DaojiTextKey.navJournal, vocabularyLevel),
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: DaojiText.resolve(DaojiTextKey.navReflection, vocabularyLevel),
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: DaojiText.resolve(DaojiTextKey.navMarketplace, vocabularyLevel),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: DaojiText.resolve(DaojiTextKey.navProfile, vocabularyLevel),
          ),
        ],
      ),
    );
  }
}
