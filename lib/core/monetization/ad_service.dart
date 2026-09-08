import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdService {
  bool get isAdAvailable;
  Widget getBannerAdWidget({VoidCallback? onAdClosed});
  Future<bool> showInterstitialAd(
    BuildContext context, {
    required String placement,
    VoidCallback? onDismissed,
  });
  Future<bool> showRewardedVideo(
    BuildContext context, {
    required String placement,
    required VoidCallback onReward,
  });
}

/// Live units require an explicit release build opt-in. Defaults always use
/// Google's sample inventory, including release builds used for testing.
class AdMobUnitIds {
  static const useTestAds =
      !kReleaseMode || !bool.fromEnvironment('ADMOB_USE_LIVE_ADS');
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;
  static String get bannerAdUnitId => useTestAds
      ? (_ios
            ? 'ca-app-pub-3940256099942544/2934735716'
            : 'ca-app-pub-3940256099942544/6300978111')
      : (_ios
            ? const String.fromEnvironment('ADMOB_IOS_BANNER_ID')
            : const String.fromEnvironment('ADMOB_ANDROID_BANNER_ID'));
  static String get interstitialAdUnitId => useTestAds
      ? (_ios
            ? 'ca-app-pub-3940256099942544/4411468910'
            : 'ca-app-pub-3940256099942544/1033173712')
      : (_ios
            ? const String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID')
            : const String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_ID'));
  static String get rewardedAdUnitId => useTestAds
      ? (_ios
            ? 'ca-app-pub-3940256099942544/1712485313'
            : 'ca-app-pub-3940256099942544/5224354917')
      : (_ios
            ? const String.fromEnvironment('ADMOB_IOS_REWARDED_ID')
            : const String.fromEnvironment('ADMOB_ANDROID_REWARDED_ID'));
  static bool get configured =>
      [bannerAdUnitId, interstitialAdUnitId, rewardedAdUnitId].every(
        (id) =>
            RegExp(r'^ca-app-pub-\d{16}/\d{10}$').hasMatch(id) &&
            (useTestAds || !id.startsWith('ca-app-pub-3940256099942544/')),
      );
}

class AdMobService implements AdService {
  static final instance = AdMobService._();
  AdMobService._();
  final ValueNotifier<bool> ready = ValueNotifier(false);
  Future<void>? _initialization;
  bool _busy = false;
  DateTime _lastFullScreen = DateTime.now();
  int _transitions = 0;
  static const _request = AdRequest(nonPersonalizedAds: true);

  @override
  bool get isAdAvailable => ready.value && !_busy;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (!AdMobUnitIds.supported || !AdMobUnitIds.configured) return;
    try {
      // This learning game is child-directed: do not infer adulthood from the
      // parent gate. UMP does not forward these flags to the ads SDK.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(tagForUnderAgeOfConsent: true),
        () {
          ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (!updated.isCompleted) updated.complete();
          });
        },
        (error) {
          if (!updated.isCompleted) updated.complete();
        },
      );
      await updated.future.timeout(const Duration(seconds: 30));
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      ready.value = true;
    } catch (error) {
      debugPrint('Ads unavailable: $error');
    }
  }

  Future<void> showPrivacyOptions(BuildContext context) async {
    if (!AdMobUnitIds.supported || _busy) return;
    _busy = true;
    ready.value = false; // Remove banners while privacy choices change.
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      if (status == PrivacyOptionsRequirementStatus.required) {
        final finished = Completer<void>();
        ConsentForm.showPrivacyOptionsForm((error) {
          if (!finished.isCompleted) finished.complete();
        });
        await finished.future;
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No advertising privacy choices are required at this time.',
            ),
          ),
        );
      }
      if (await ConsentInformation.instance.canRequestAds() &&
          AdMobUnitIds.configured) {
        await MobileAds.instance.initialize();
        ready.value = true;
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Privacy settings are unavailable. Please try again later.',
            ),
          ),
        );
      }
    } finally {
      _busy = false;
    }
  }

  @override
  Widget getBannerAdWidget({VoidCallback? onAdClosed}) =>
      ValueListenableBuilder<bool>(
        valueListenable: ready,
        builder: (_, enabled, _) =>
            enabled ? const AdMobBannerWidget() : const SizedBox.shrink(),
      );

  @override
  Future<bool> showInterstitialAd(
    BuildContext context, {
    required String placement,
    VoidCallback? onDismissed,
  }) async {
    // No exit ads. Only every third next-level transition, at least 120 seconds
    // after launch or another full-screen ad. Failed requests never block play.
    if (_busy) return false;
    try {
      if (placement != 'next_level' ||
          !isAdAvailable ||
          ++_transitions % 3 != 0 ||
          DateTime.now().difference(_lastFullScreen) <
              const Duration(seconds: 120))
        return false;
      _busy = true;
      final loaded = Completer<InterstitialAd?>();
      var expired = false;
      await InterstitialAd.load(
        adUnitId: AdMobUnitIds.interstitialAdUnitId,
        request: _request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (expired) {
              ad.dispose();
            } else {
              loaded.complete(ad);
            }
          },
          onAdFailedToLoad: (_) {
            if (!loaded.isCompleted) loaded.complete(null);
          },
        ),
      );
      final ad = await loaded.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          expired = true;
          return null;
        },
      );
      if (ad == null) return false;
      if (!context.mounted || !ready.value) {
        ad.dispose();
        return false;
      }
      final dismissed = Completer<bool>();
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (!dismissed.isCompleted) dismissed.complete(true);
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose();
          if (!dismissed.isCompleted) dismissed.complete(false);
        },
      );
      try {
        await ad.show();
      } catch (_) {
        ad.dispose();
        return false;
      }
      _lastFullScreen = DateTime.now();
      return await dismissed.future;
    } catch (error) {
      debugPrint('Interstitial unavailable: $error');
      return false;
    } finally {
      _busy = false;
      if (context.mounted) onDismissed?.call();
    }
  }

  @override
  Future<bool> showRewardedVideo(
    BuildContext context, {
    required String placement,
    required VoidCallback onReward,
  }) async {
    if (_busy || !context.mounted) return false;
    // Explicit opt-in includes the exact offered reward, even for the home icon.
    final reward = switch (placement) {
      'home_screen_gift' => '25 coins',
      'level_complete_bonus' => '30 coins and 20 XP',
      'challenge_complete_bonus' => '50 coins and 30 XP',
      _ => 'a bonus',
    };
    _busy = true;
    try {
      if (!ready.value) {
        _unavailable(context);
        return false;
      }
      final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Watch an ad?'),
          content: Text(
            'Watch a video ad to earn $reward. You can keep playing without watching.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Watch ad'),
            ),
          ],
        ),
      );
      if (accepted != true || !context.mounted) return false;
      final loaded = Completer<RewardedAd?>();
      var expired = false;
      await RewardedAd.load(
        adUnitId: AdMobUnitIds.rewardedAdUnitId,
        request: _request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (expired) {
              ad.dispose();
            } else {
              loaded.complete(ad);
            }
          },
          onAdFailedToLoad: (_) {
            if (!loaded.isCompleted) loaded.complete(null);
          },
        ),
      );
      final ad = await loaded.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          expired = true;
          return null;
        },
      );
      if (ad == null) {
        if (context.mounted) _unavailable(context);
        return false;
      }
      if (!context.mounted || !ready.value) {
        ad.dispose();
        return false;
      }
      var earned = false;
      final dismissed = Completer<bool>();
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (!dismissed.isCompleted) dismissed.complete(earned);
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose();
          if (!dismissed.isCompleted) dismissed.complete(false);
        },
      );
      try {
        await ad.show(
          onUserEarnedReward: (_, _) {
            if (!earned) {
              earned = true;
              if (context.mounted) onReward();
            }
          },
        );
      } catch (_) {
        ad.dispose();
        return false;
      }
      _lastFullScreen = DateTime.now();
      return await dismissed.future;
    } catch (error) {
      if (context.mounted) _unavailable(context);
      return false;
    } finally {
      _busy = false;
    }
  }

  void _unavailable(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No ad available right now. Please try again later.'),
        ),
      );
}

class AdMobBannerWidget extends StatefulWidget {
  const AdMobBannerWidget({super.key});
  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _ad;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: AdMobUnitIds.bannerAdUnitId,
      size: AdSize.banner,
      request: AdMobService._request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _ad = null;
        },
      ),
    );
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      await _ad?.load();
    } catch (_) {
      _ad?.dispose();
      _ad = null;
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      if (!_loaded || _ad == null || constraints.maxWidth < 320)
        return const SizedBox.shrink();
      return SizedBox(width: 320, height: 50, child: AdWidget(ad: _ad!));
    },
  );
}
