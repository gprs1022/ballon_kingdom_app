import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_colors.dart';

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
  bool get isAppOpenAdAvailable;
  void loadAppOpenAd();
  Future<bool> showAppOpenAdIfAvailable({VoidCallback? onDismissed});
  Future<bool> loadAndShowAppOpenAd(BuildContext context);
  bool get appOpenAdsEnabled;
  set appOpenAdsEnabled(bool value);
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
  static String get appOpenAdUnitId => useTestAds
      ? (_ios
            ? 'ca-app-pub-3940256099942544/5575463023'
            : 'ca-app-pub-3940256099942544/9257395921')
      : (_ios
            ? const String.fromEnvironment('ADMOB_IOS_APP_OPEN_ID')
            : const String.fromEnvironment('ADMOB_ANDROID_APP_OPEN_ID'));

  static bool get isAppOpenConfigured =>
      RegExp(r'^ca-app-pub-\d{16}/\d{10}$').hasMatch(appOpenAdUnitId) &&
      (useTestAds || !appOpenAdUnitId.startsWith('ca-app-pub-3940256099942544/'));

  static bool get configured =>
      [bannerAdUnitId, interstitialAdUnitId, rewardedAdUnitId].every(
        (id) =>
            RegExp(r'^ca-app-pub-\d{16}/\d{10}$').hasMatch(id) &&
            (useTestAds || !id.startsWith('ca-app-pub-3940256099942544/')),
      );
}

class AdMobService with WidgetsBindingObserver implements AdService {
  static final instance = AdMobService._();
  AdMobService._();
  final ValueNotifier<bool> ready = ValueNotifier(false);
  Future<void>? _initialization;
  bool _busy = false;
  DateTime _lastFullScreen = DateTime.now();
  int _transitions = 0;
  static const _request = AdRequest(nonPersonalizedAds: true);

  // App Open Ad state
  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadTime;
  bool _isLoadingAppOpenAd = false;
  bool _isShowingAppOpenAd = false;
  bool _appOpenAdsEnabled = true;
  bool _observerRegistered = false;

  @override
  bool get isAdAvailable => ready.value && !_busy;

  @override
  bool get appOpenAdsEnabled => _appOpenAdsEnabled;

  @override
  set appOpenAdsEnabled(bool value) {
    _appOpenAdsEnabled = value;
  }

  @override
  bool get isAppOpenAdAvailable =>
      _appOpenAd != null &&
      _appOpenLoadTime != null &&
      DateTime.now().difference(_appOpenLoadTime!).inHours < 4;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (!AdMobUnitIds.supported || !AdMobUnitIds.configured) return;
    try {
      // This learning game is child-directed: do not infer adulthood from the
      // parent gate. UMP does not forward these flags to the ads SDK.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          ageRestrictedTreatment: AgeRestrictedTreatment.child,
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );

      // In production/live builds, request UMP consent update.
      // In test mode, we do not block ads initialization on UMP.
      if (!AdMobUnitIds.useTestAds) {
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
        await updated.future.timeout(const Duration(seconds: 5), onTimeout: () {
          if (!updated.isCompleted) updated.complete();
        });
        if (!await ConsentInformation.instance.canRequestAds()) {
          debugPrint('AdMob: Consent not ready');
          return;
        }
      }

      await MobileAds.instance.initialize();
      ready.value = true;
      if (!_observerRegistered) {
        WidgetsBinding.instance.addObserver(this);
        _observerRegistered = true;
      }
      loadAppOpenAd();
      debugPrint('AdMob initialized successfully. Test mode: ${AdMobUnitIds.useTestAds}');
    } catch (error) {
      debugPrint('Ads unavailable: $error');
      // If error occurs in test mode, ensure MobileAds is still initialized
      if (AdMobUnitIds.useTestAds) {
        try {
          await MobileAds.instance.initialize();
          ready.value = true;
          loadAppOpenAd();
        } catch (_) {}
      }
    }
  }

  Future<void> showPrivacyOptions(BuildContext context) async {
    if (!AdMobUnitIds.supported || _busy) return;
    _busy = true;
    ready.value = false; // Remove banners while privacy choices change.
    _appOpenAd?.dispose();
    _appOpenAd = null;
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      if (status == PrivacyOptionsRequirementStatus.required) {
        final finished = Completer<void>();
        ConsentForm.showPrivacyOptionsForm((error) {
          if (!finished.isCompleted) {
            if (error != null) {
              finished.completeError(error);
            } else {
              finished.complete();
            }
          }
        });
        await finished.future;
      } else if (context.mounted) {
        AdCreativeDialog.show(
          context,
          emoji: '🛡️',
          title: 'Privacy Settings 🛡️',
          message:
              'No advertising privacy choices are required at this time.',
          primaryButtonText: 'Great, Got It! 🌟',
          primaryButtonColor: AppColors.primaryBlue,
          badgeGradient: const [Color(0xFF81D4FA), Color(0xFF0288D1)],
        );
      }
      if (await ConsentInformation.instance.canRequestAds() &&
          AdMobUnitIds.configured) {
        await MobileAds.instance.initialize();
        ready.value = true;
        loadAppOpenAd();
      }
    } catch (error) {
      if (context.mounted) {
        AdCreativeDialog.show(
          context,
          emoji: '🛡️',
          title: 'Privacy Notice 🛡️',
          message:
              'Privacy settings are unavailable. Please try again later.',
          primaryButtonText: 'Okay 🌟',
          primaryButtonColor: AppColors.coralRed,
          badgeGradient: const [Color(0xFFFF8A80), Color(0xFFFF5252)],
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
  void loadAppOpenAd() {
    if (!AdMobUnitIds.supported || !AdMobUnitIds.isAppOpenConfigured) return;
    if (!ready.value || _isLoadingAppOpenAd || isAppOpenAdAvailable) return;

    _isLoadingAppOpenAd = true;
    AppOpenAd.load(
      adUnitId: AdMobUnitIds.appOpenAdUnitId,
      request: _request,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isLoadingAppOpenAd = false;
          debugPrint('AppOpenAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _isLoadingAppOpenAd = false;
          _appOpenAd = null;
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  @override
  Future<bool> showAppOpenAdIfAvailable({VoidCallback? onDismissed}) async {
    if (!_appOpenAdsEnabled ||
        !AdMobUnitIds.supported ||
        !isAdAvailable ||
        _isShowingAppOpenAd ||
        _busy) {
      onDismissed?.call();
      return false;
    }

    // Cooldown check: at least 60 seconds after launch or another full-screen ad in live mode
    if (!AdMobUnitIds.useTestAds &&
        DateTime.now().difference(_lastFullScreen) <
            const Duration(seconds: 60)) {
      onDismissed?.call();
      return false;
    }

    // Expired or missing ad
    if (!isAppOpenAdAvailable) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      onDismissed?.call();
      return false;
    }

    final ad = _appOpenAd!;
    _isShowingAppOpenAd = true;
    _busy = true;

    final dismissed = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AppOpenAd showed full screen content.');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isShowingAppOpenAd = false;
        _busy = false;
        _lastFullScreen = DateTime.now();
        loadAppOpenAd(); // Preload next ad
        onDismissed?.call();
        if (!dismissed.isCompleted) dismissed.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AppOpenAd failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _isShowingAppOpenAd = false;
        _busy = false;
        loadAppOpenAd(); // Try loading again
        onDismissed?.call();
        if (!dismissed.isCompleted) dismissed.complete(false);
      },
    );

    try {
      await ad.show();
      return await dismissed.future;
    } catch (error) {
      debugPrint('Error showing AppOpenAd: $error');
      ad.dispose();
      _appOpenAd = null;
      _isShowingAppOpenAd = false;
      _busy = false;
      loadAppOpenAd();
      onDismissed?.call();
      return false;
    }
  }

  @override
  Future<bool> loadAndShowAppOpenAd(BuildContext context) async {
    if (!AdMobUnitIds.supported) return false;
    if (isAppOpenAdAvailable) {
      return await showAppOpenAdIfAvailable();
    }
    if (!ready.value) {
      if (context.mounted) _unavailable(context);
      return false;
    }
    _isLoadingAppOpenAd = true;
    final loaded = Completer<bool>();
    AppOpenAd.load(
      adUnitId: AdMobUnitIds.appOpenAdUnitId,
      request: _request,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) async {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isLoadingAppOpenAd = false;
          final result = await showAppOpenAdIfAvailable();
          if (!loaded.isCompleted) loaded.complete(result);
        },
        onAdFailedToLoad: (error) {
          _isLoadingAppOpenAd = false;
          debugPrint('AppOpenAd failed to load: $error');
          if (!loaded.isCompleted) loaded.complete(false);
        },
      ),
    );
    final shown = await loaded.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        _isLoadingAppOpenAd = false;
        return false;
      },
    );
    if (!shown && context.mounted) {
      _unavailable(context);
    }
    return shown;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _appOpenAdsEnabled) {
      unawaited(showAppOpenAdIfAvailable());
    }
  }

  void dispose() {
    if (_observerRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _observerRegistered = false;
    }
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

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
      if (!AdMobUnitIds.useTestAds) {
        if (placement != 'next_level' ||
            !isAdAvailable ||
            ++_transitions % 3 != 0 ||
            DateTime.now().difference(_lastFullScreen) <
                const Duration(seconds: 120)) {
          return false;
        }
      } else {
        if (!isAdAvailable) return false;
      }
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
        const Duration(seconds: 8),
        onTimeout: () {
          expired = true;
          return null;
        },
      );
      if (ad == null) return false;
      if (!context.mounted ||
          !ready.value ||
          ModalRoute.of(context)?.isCurrent == false) {
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
      'ad_balloon_screen_blast' => '25 bonus coins and an instant Screen Blast',
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
      final isBlast = placement == 'ad_balloon_screen_blast';
      final isRevive = placement == 'revive_avoid_balloon';
      final emoji = isRevive ? '💖' : (isBlast ? '💥' : '🎁');
      final title = isRevive
          ? 'Second Chance Revive! 💖'
          : (isBlast ? 'Bonus Screen Blast! 🎬' : 'Watch an Ad? 🎬');
      final message = isRevive
          ? 'Watch a quick video to clear avoid hazards and keep your score and game going!'
          : (isBlast
              ? 'Watch a short video to pop every balloon on screen, heal a heart, and earn 25 bonus coins!'
              : 'Watch a video ad to earn $reward. You can keep playing without watching.');
      final primaryButtonText = isRevive
          ? 'Revive Me! 💖'
          : (isBlast ? 'Blast All Balloons! ✨' : 'Watch Ad ✨');
      final secondaryButtonText = isRevive ? 'No Thanks' : 'Keep Playing';
      final primaryButtonColor = isRevive
          ? const Color(0xFFFF4081)
          : (isBlast ? const Color(0xFFFFD700) : const Color(0xFF00E676));
      final badgeGradient = isRevive
          ? const [Color(0xFFFF5252), Color(0xFFFF4081)]
          : (isBlast
              ? const [Color(0xFFE040FB), Color(0xFF7C4DFF)]
              : const [Color(0xFF64B5F6), Color(0xFF1E88E5)]);

      final accepted = await AdCreativeDialog.show(
        context,
        emoji: emoji,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        primaryButtonColor: primaryButtonColor,
        badgeGradient: badgeGradient,
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
      if (!context.mounted ||
          !ready.value ||
          ModalRoute.of(context)?.isCurrent == false) {
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

  void _unavailable(BuildContext context) {
    if (!context.mounted) return;
    AdCreativeDialog.show(
      context,
      emoji: '🎈',
      title: 'Ad Not Ready 🎈',
      message: 'No ad available right now. Please try again later.',
      tip: 'Keep popping balloons! Rewards will be ready soon.',
      primaryButtonText: 'Awesome, Got It! 🌟',
      primaryButtonColor: AppColors.candyPink,
    );
  }
}

/// A common, playful, creative dialog used for all ad-related alerts and confirmations.
class AdCreativeDialog extends StatelessWidget {
  final String emoji;
  final String title;
  final String message;
  final String? tip;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final Color primaryButtonColor;
  final List<Color> badgeGradient;

  const AdCreativeDialog({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
    this.tip,
    this.primaryButtonText = 'Awesome, Got It! 🌟',
    this.secondaryButtonText,
    this.primaryButtonColor = AppColors.candyPink,
    this.badgeGradient = const [Color(0xFFFFD54F), Color(0xFFFFB300)],
  });

  static Future<bool?> show(
    BuildContext context, {
    required String emoji,
    required String title,
    required String message,
    String? tip,
    String primaryButtonText = 'Awesome, Got It! 🌟',
    String? secondaryButtonText,
    Color primaryButtonColor = AppColors.candyPink,
    List<Color> badgeGradient = const [Color(0xFFFFD54F), Color(0xFFFFB300)],
  }) {
    if (!context.mounted) return Future.value(null);
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdCreativeDialog(
        emoji: emoji,
        title: title,
        message: message,
        tip: tip,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        primaryButtonColor: primaryButtonColor,
        badgeGradient: badgeGradient,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Dialog Card
          Container(
            margin: const EdgeInsets.only(top: 36),
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFE1F5FE),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cheerful Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                // Required Notice Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF37474F),
                    height: 1.35,
                  ),
                ),
                if (tip != null) ...[
                  const SizedBox(height: 16),
                  // Friendly Tip Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFB3E5FC),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '✨',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip!,
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0277BD),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),

                // Action Buttons
                if (secondaryButtonText != null)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFCFD8DC),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              secondaryButtonText!,
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF546E7A),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              backgroundColor: primaryButtonColor,
                              foregroundColor: Colors.white,
                              shadowColor: primaryButtonColor.withValues(
                                alpha: 0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              primaryButtonText,
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: primaryButtonColor,
                        foregroundColor: Colors.white,
                        shadowColor: primaryButtonColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        primaryButtonText,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Floating Top Avatar/Icon Badge
          Positioned(
            top: 0,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: badgeGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: badgeGradient.last.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3.5),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility alias for [AdCreativeDialog].
class AdUnavailableDialog extends StatelessWidget {
  const AdUnavailableDialog({super.key});

  @override
  Widget build(BuildContext context) => const AdCreativeDialog(
        emoji: '🎈',
        title: 'Ad Not Ready 🎈',
        message: 'No ad available right now. Please try again later.',
        tip: 'Keep popping balloons! Rewards will be ready soon.',
        primaryButtonText: 'Awesome, Got It! 🌟',
        primaryButtonColor: AppColors.candyPink,
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
  VoidCallback? _readyListener;

  @override
  void initState() {
    super.initState();
    if (AdMobService.instance.ready.value) {
      _createAndLoad();
    } else {
      _readyListener = () {
        if (AdMobService.instance.ready.value && _ad == null && mounted) {
          _createAndLoad();
        }
      };
      AdMobService.instance.ready.addListener(_readyListener!);
    }
  }

  void _createAndLoad() {
    if (!AdMobUnitIds.supported || !AdMobUnitIds.configured) return;
    _ad = BannerAd(
      adUnitId: AdMobUnitIds.bannerAdUnitId,
      size: AdSize.banner,
      request: AdMobService._request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
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
    if (_readyListener != null) {
      AdMobService.instance.ready.removeListener(_readyListener!);
    }
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      if (!_loaded || _ad == null || constraints.maxWidth < 320) {
        return const SizedBox.shrink();
      }
      return SizedBox(width: 320, height: 50, child: AdWidget(ad: _ad!));
    },
  );
}
