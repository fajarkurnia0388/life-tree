import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/core/domain/app_constants.dart';

void main() {
  test('FrictionReason constants have consistent values', () {
    expect(FrictionReason.kurangWaktu, 'Kurang_Waktu');
    expect(FrictionReason.kelelahan, 'Kelelahan');
    expect(FrictionReason.lupa, 'Lupa');
  });
}
