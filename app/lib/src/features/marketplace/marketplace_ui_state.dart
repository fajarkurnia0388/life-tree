import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared marketplace filter/search UI state.
///
/// Tab shell and full-screen push (`/marketplace` from add-habit) both watch
/// this provider so domain/type/sort/query stay consistent across entry points.
///
/// Policy (Wave 4):
/// - **Tab** = browse home (IndexedStack keeps the widget alive).
/// - **Push** `/marketplace` = catalog mode; pop returns to previous screen
///   (e.g. add-habit). Filters are shared via this provider, not local State.
class MarketplaceUiState {
  final String templateType; // habit | core_value
  final String domain; // Semua | Tubuh | ...
  final String sortBy; // Terpopuler | Terbaik | Terbaru
  final String query;

  const MarketplaceUiState({
    this.templateType = 'habit',
    this.domain = 'Semua',
    this.sortBy = 'Terpopuler',
    this.query = '',
  });

  MarketplaceUiState copyWith({
    String? templateType,
    String? domain,
    String? sortBy,
    String? query,
  }) {
    return MarketplaceUiState(
      templateType: templateType ?? this.templateType,
      domain: domain ?? this.domain,
      sortBy: sortBy ?? this.sortBy,
      query: query ?? this.query,
    );
  }
}

class MarketplaceUiController extends StateNotifier<MarketplaceUiState> {
  MarketplaceUiController() : super(const MarketplaceUiState());

  void setTemplateType(String type) {
    if (type == state.templateType) return;
    state = state.copyWith(templateType: type);
  }

  void setDomain(String domain) {
    if (domain == state.domain) return;
    state = state.copyWith(domain: domain);
  }

  void setSortBy(String sortBy) {
    if (sortBy == state.sortBy) return;
    state = state.copyWith(sortBy: sortBy);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void clearQuery() {
    if (state.query.isEmpty) return;
    state = state.copyWith(query: '');
  }
}

final marketplaceUiProvider =
    StateNotifierProvider<MarketplaceUiController, MarketplaceUiState>((ref) {
  return MarketplaceUiController();
});
