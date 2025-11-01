import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../../lib/core/premium/premium_service.dart';
import '../../../lib/core/storage/local_storage_service.dart';
import '../../../lib/domain/premium/premium_plan.dart';

@GenerateMocks([LocalStorageService])
import 'premium_service_test.mocks.dart';

void main() {
  group('PremiumService', () {
    late PremiumService premiumService;
    late MockLocalStorageService mockLocalStorage;

    setUp(() {
      mockLocalStorage = MockLocalStorageService();
      premiumService = PremiumService(mockLocalStorage);
    });

    group('getCurrentTier', () {
      test('returns free tier when no subscription exists', () async {
        when(
          mockLocalStorage.getString('premium_subscription'),
        ).thenAnswer((_) async => null);

        final tier = await premiumService.getCurrentTier();

        expect(tier, PremiumTier.free);
      });

      test(
        'returns subscription tier when active subscription exists',
        () async {
          final subscription = PremiumSubscription(
            id: 'test_sub',
            userId: 'test_user',
            planId: 'premium',
            tier: PremiumTier.premium,
            startDate: DateTime.now(),
            endDate: DateTime.now().add(Duration(days: 30)),
            status: SubscriptionStatus.active,
            billingCycle: BillingCycle.monthly,
          );

          when(
            mockLocalStorage.getString('premium_subscription'),
          ).thenAnswer((_) async => subscription.toJson());

          final tier = await premiumService.getCurrentTier();

          expect(tier, PremiumTier.premium);
        },
      );
    });

    group('hasFeature', () {
      test('returns false for premium features on free tier', () async {
        when(
          mockLocalStorage.getString('premium_subscription'),
        ).thenAnswer((_) async => null);

        final hasExport = await premiumService.hasFeature(FeatureType.export);
        final hasBackup = await premiumService.hasFeature(FeatureType.backup);

        expect(hasExport, false);
        expect(hasBackup, false);
      });

      test('returns true for premium features on premium tier', () async {
        final subscription = PremiumSubscription(
          id: 'test_sub',
          userId: 'test_user',
          planId: 'premium',
          tier: PremiumTier.premium,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          status: SubscriptionStatus.active,
          billingCycle: BillingCycle.monthly,
        );

        when(
          mockLocalStorage.getString('premium_subscription'),
        ).thenAnswer((_) async => subscription.toJson());

        final hasExport = await premiumService.hasFeature(FeatureType.export);
        final hasBackup = await premiumService.hasFeature(FeatureType.backup);

        expect(hasExport, true);
        expect(hasBackup, true);
      });
    });
  });
}
