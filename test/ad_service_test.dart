import 'package:balloonpop/core/monetization/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Unavailable interstitial continues navigation exactly once', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const Scaffold();
          },
        ),
      ),
    );
    var navigations = 0;
    final shown = await AdMobService.instance.showInterstitialAd(
      context,
      placement: 'next_level',
      onDismissed: () => navigations++,
    );
    expect(shown, isFalse);
    expect(navigations, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Unavailable rewarded ad never grants a fake reward', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const Scaffold();
          },
        ),
      ),
    );
    var rewards = 0;
    final earned = await AdMobService.instance.showRewardedVideo(
      context,
      placement: 'home_screen_gift',
      onReward: () => rewards++,
    );
    await tester.pump();
    expect(earned, isFalse);
    expect(rewards, 0);
    expect(
      find.text('No ad available right now. Please try again later.'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Unavailable AppOpenAd triggers onDismissed callback and returns false', (
    tester,
  ) async {
    var dismissed = 0;
    final shown = await AdMobService.instance.showAppOpenAdIfAvailable(
      onDismissed: () => dismissed++,
    );
    expect(shown, isFalse);
    expect(dismissed, 1);
  });

  test('AppOpenAd respects appOpenAdsEnabled flag', () async {
    final service = AdMobService.instance;
    service.appOpenAdsEnabled = false;
    expect(service.appOpenAdsEnabled, isFalse);

    var dismissed = 0;
    final shown = await service.showAppOpenAdIfAvailable(
      onDismissed: () => dismissed++,
    );
    expect(shown, isFalse);
    expect(dismissed, 1);

    // Reset back to true
    service.appOpenAdsEnabled = true;
    expect(service.appOpenAdsEnabled, isTrue);
  });

  test('AdMobUnitIds app open unit id is valid in test environment', () {
    expect(AdMobUnitIds.appOpenAdUnitId, isNotEmpty);
    expect(AdMobUnitIds.isAppOpenConfigured, isTrue);
  });

  testWidgets('AdCreativeDialog renders custom message, emoji, and dismisses on tap', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const Scaffold();
          },
        ),
      ),
    );

    bool? result;
    AdCreativeDialog.show(
      context,
      emoji: '🎈',
      title: 'Ad Not Ready 🎈',
      message: 'No ad available right now. Please try again later.',
      primaryButtonText: 'Awesome, Got It! 🌟',
    ).then((val) => result = val);

    await tester.pumpAndSettle();
    expect(find.text('Ad Not Ready 🎈'), findsOneWidget);
    expect(
      find.text('No ad available right now. Please try again later.'),
      findsOneWidget,
    );
    expect(find.text('Awesome, Got It! 🌟'), findsOneWidget);

    await tester.tap(find.text('Awesome, Got It! 🌟'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.byType(AdCreativeDialog), findsNothing);
  });

  testWidgets('loadAndShowAppOpenAd handles unready ad service gracefully', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const Scaffold();
          },
        ),
      ),
    );

    final shown = await AdMobService.instance.loadAndShowAppOpenAd(context);
    expect(shown, isFalse);
    await tester.pumpAndSettle();
    if (find.text('Awesome, Got It! 🌟').evaluate().isNotEmpty) {
      await tester.tap(find.text('Awesome, Got It! 🌟'));
      await tester.pumpAndSettle();
    }
  });
}
