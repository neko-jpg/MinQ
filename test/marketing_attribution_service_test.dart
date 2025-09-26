import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/data/services/marketing_attribution_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object?>{});
  });

  test('captures UTM parameters from incoming URI', () async {
    final prefs = LocalPreferencesService(now: () => DateTime.utc(2024, 5, 1));
    final service = MarketingAttributionService(prefs);
    await service.captureUri(Uri.parse('minq://record?utm_source=ad&utm_medium=cpc&utm_campaign=habit&utm_content=copy&utm_term=morning'));

    final snapshot = await prefs.loadAttribution();
    expect(snapshot, isNotNull);
    expect(snapshot!.source, 'ad');
    expect(snapshot.medium, 'cpc');
    expect(snapshot.campaign, 'habit');
    expect(snapshot.content, 'copy');
    expect(snapshot.term, 'morning');
  });

  test('ignores URIs without UTM parameters', () async {
    final prefs = LocalPreferencesService();
    final service = MarketingAttributionService(prefs);
    await service.captureUri(Uri.parse('minq://record?foo=bar'));
    expect(await prefs.loadAttribution(), isNull);
  });
}
