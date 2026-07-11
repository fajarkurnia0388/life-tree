import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/button_theme.dart';
import '../../../data/local_db/database.dart';
import '../../../core/providers/db_provider.dart';
import '../../../core/services/snackbar_service.dart';
import '../services/dashboard_action_service.dart';

class TreeSkinShopBottomSheet extends ConsumerStatefulWidget {
  final UserProfile profile;
  final VoidCallback onSuccess;
  const TreeSkinShopBottomSheet({
    super.key,
    required this.profile,
    required this.onSuccess,
  });

  @override
  ConsumerState<TreeSkinShopBottomSheet> createState() =>
      _TreeSkinShopBottomSheetState();
}

class _TreeSkinShopBottomSheetState
    extends ConsumerState<TreeSkinShopBottomSheet> {
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _skins = [
    {
      'id': 'Default',
      'name': 'Oak Klasik 🌱',
      'description':
          'Penampilan default bernuansa hijau sage yang menenangkan.',
      'price': 0,
      'preview': '🌱 🌿 🌳 🌲',
    },
    {
      'id': 'Sakura',
      'name': 'Sakura Jepang 🌸',
      'description':
          'Pohon sakura dengan kelopak bunga merah muda yang mekar indah.',
      'price': 15000,
      'preview': '🌸🌱 🌸🌿 🌸🌳 🌸🌲',
    },
    {
      'id': 'Maple',
      'name': 'Golden Maple 🍁',
      'description':
          'Penampilan musim gugur dengan warna emas kemerahan yang hangat.',
      'price': 15000,
      'preview': '🍁🌱 🍁🌿 🍁🌳 🍁🌲',
    },
    {
      'id': 'Bonsai',
      'name': 'Bonsai Zen 🪴',
      'description':
          'Tanaman kerdil tradisional untuk melatih kedisiplinan dan ketenangan.',
      'price': 25000,
      'preview': '🪴🌱 🪴🌿 🪴🌳 🪴🌲',
    },
    {
      'id': 'Bamboo_Immortal',
      'name': 'Bamboo Immortal 🎋',
      'description':
          'Bambu abadi dengan aura kultivasi. Melambangkan ketahanan dan fleksibilitas jiwa.',
      'price': 30000,
      'preview': '🎋🌱 🎋🌿 🎋🌳 🎋🌲',
    },
    {
      'id': 'Peach_Blossom',
      'name': 'Peach Blossom Paradise 🌺',
      'description':
          'Pohon persik abadi dari surga kultivator. Melambangkan umur panjang dan ketenangan jiwa.',
      'price': 30000,
      'preview': '🌺🌱 🌺🌿 🌺🌳 🌺🌲',
    },
    {
      'id': 'Ancient_Pine',
      'name': 'Ancient Pine 🌲',
      'description':
          'Pinus kuno yang berdiri ribuan tahun. Melambangkan ketekunan, stabilitas, dan kebijaksanaan.',
      'price': 35000,
      'preview': '🌲🌱 🌲🌿 🌲🌳 🌲',
    },
  ];

  Future<void> _selectSkin(String skinId) async {
    try {
      await ref.read(dashboardActionServiceProvider).updateUserSkin(widget.profile.userId, skinId);
      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        SnackBarService.showSuccess(context, 'Tampilan pohon berhasil diubah ke skin ini!');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'Gagal menerapkan skin: $e');
      }
    }
  }

  Future<void> _buySkin(Map<String, dynamic> skin) async {
    final db = ref.read(dbProvider);
    final skinId = skin['id'] as String;
    final priceStr =
        'Rp ${(skin['price'] as int).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';

    final proceedPayment = await showDialog<bool>(
      context: context,
      builder: (context) {
        String method = 'Google Play';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Simulasi Transaksi Premium'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Anda akan membeli skin premium:\n"${skin['name']}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Harga: $priceStr',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Metode Pembayaran:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: method,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Google Play',
                        child: Text('GPay / Google Play Store'),
                      ),
                      DropdownMenuItem(
                        value: 'Transfer Bank',
                        child: Text('Transfer Bank (Virtual Account)'),
                      ),
                      DropdownMenuItem(
                        value: 'e-Wallet',
                        child: Text('e-Wallet (QRIS)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          method = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: AppButtonStyles.secondary(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: AppButtonStyles.primary(context),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Bayar Sekarang'),
                ),
              ],
            );
          },
        );
      },
    );

    if (proceedPayment == true) {
      setState(() {
        _isProcessing = true;
      });

      // Simulate payment delay
      await Future.delayed(const Duration(milliseconds: 600));

      try {
        final updatedUnlocked = '${widget.profile.unlockedSkins},$skinId';
        await ref.read(dashboardActionServiceProvider).purchaseUserSkin(
          widget.profile.userId,
          updatedUnlocked,
          skinId,
        );

        widget.onSuccess();

        if (mounted) {
          Navigator.pop(context);
          SnackBarService.showSuccess(
            context,
            'Pembelian berhasil! Skin "${skin['name']}" telah diaktifkan.',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(context, 'Transaksi gagal: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlockedList = widget.profile.unlockedSkins.split(',');

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Toko Skin Pohon 🎨',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Visualisasikan konsistensi Anda dengan gaya pohon unik.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_isProcessing)
            const SizedBox(
              height: 250,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memproses transaksi pembayaran...'),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _skins.length,
              itemBuilder: (context, index) {
                final s = _skins[index];
                final isUnlocked =
                    widget.profile.isDeveloperMode ||
                    unlockedList.contains(s['id']);
                final isSelected = widget.profile.selectedSkin == s['id'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Text(
                      (s['preview'] as String).split(' ').last,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(
                      s['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['description'],
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Preview: ${s['preview']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : isUnlocked
                        ? OutlinedButton(
                            onPressed: () => _selectSkin(s['id']),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Pakai',
                              style: TextStyle(fontSize: 12),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () => _buySkin(s),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              s['price'] == 0
                                  ? 'Gratis'
                                  : 'Rp ${(s['price'] as int).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
