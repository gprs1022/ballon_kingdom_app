# AdMob setup for Balloon Kingdom

The app uses google_mobile_ads 9.1.0 for Android and iOS. Web and desktop have no ads. Google sample ad units and sample native application IDs are the default, even in release builds. No live monetization has been activated.

## Implemented behavior

- UMP refreshes consent at startup, after the first frame. Ads initialize only when `canRequestAds()` allows requests; an error never blocks the game.
- This children's learning game uses `AgeRestrictedTreatment.child`, G-rated inventory, non-personalized requests and UMP under-age-of-consent treatment. This is not an age verification system; confirm the intended audience and store declarations before launch. A parent gate does not turn the child into an adult for ad requests.
- Advertising privacy choices are accessible in Parent Dashboard. UMP decides if a form is required; child treatment may mean no consent form is displayed.
- A standard banner appears on the home screen only, after loading, and is hidden for Deluxe users. No banners overlap active balloon gameplay. Narrow layouts hide the banner instead of cropping it.
- Interstitials are limited to every third next-level transition, at least 120 seconds after launch or the preceding full-screen ad. Exit/restart actions show no interstitial. Load failure/4-second timeout continues to the next level; late ads are disposed.
- Rewarded ads require an explicit confirmation showing the reward. Home: 25 coins; level result: 30 coins + 20 XP; challenge result: 50 coins + 30 XP. Rewards come only from the SDK's earned-reward callback, once per ad. No simulated ads or simulated rewards remain. Load timeout is 10 seconds; unavailable ads show a brief message. Duplicate full-screen requests are ignored.
- Existing Deluxe behavior is preserved: removes automatic banner/interstitial ads; voluntary rewarded offers remain. Existing purchases are an offline simulation, not a real billing integration.

## Configure production (owner-supplied values required)

1. Create/register each app in AdMob using its final package/bundle identifier. The Android identifier is `com.gprstech.ballonpop`.
2. Android: set `ADMOB_APP_ID=YOUR_ANDROID_ADMOB_APP_ID` in `android/gradle.properties` (or pass a Gradle project property). The manifest resolves `${adMobAppId}`. This is the app ID containing `~`, not an ad unit ID.
3. iOS: replace the sample value in `ios/Flutter/AdMob.xcconfig` with the iOS AdMob app ID. `Info.plist` resolves `$(ADMOB_APP_ID)` through Debug/Release configurations. Validate this with Xcode on macOS.
4. Provide the banner, interstitial and rewarded ad unit IDs for each target platform. Build with `--dart-define=ADMOB_USE_LIVE_ADS=true` and all three platform-specific defines:
   - Android: `ADMOB_ANDROID_BANNER_ID`, `ADMOB_ANDROID_INTERSTITIAL_ID`, `ADMOB_ANDROID_REWARDED_ID`.
   - iOS: `ADMOB_IOS_BANNER_ID`, `ADMOB_IOS_INTERSTITIAL_ID`, `ADMOB_IOS_REWARDED_ID`.
   These ad unit IDs contain `/`. They must match the native app registration. Missing/malformed/sample live units disable ad initialization. Debug/profile builds always use sample units.
5. Configure applicable Privacy & Messaging messages in AdMob, publish your privacy policy, complete account/app review and store ad/data safety/target-audience declarations, and follow AdMob app-ads.txt instructions for your publisher account. Confirm children's audience requirements and inventory eligibility. This code does not establish store/account approval.
6. Android release signing is currently the pre-existing debug signing configuration. Set up production signing separately; do not upload this test configuration to a store.

Example shape (replace every value; do not use placeholders as real IDs):

```powershell
flutter build apk --release --dart-define=ADMOB_USE_LIVE_ADS=true --dart-define=ADMOB_ANDROID_BANNER_ID=YOUR_BANNER_ID --dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=YOUR_INTERSTITIAL_ID --dart-define=ADMOB_ANDROID_REWARDED_ID=YOUR_REWARDED_ID
```

## Device verification before release

Use the default sample IDs for development. Confirm an actual Google test banner/video on Android and iOS; test offline/no-fill, skipped reward (no coins), completed reward (exactly once), rapid repeated taps, navigation during load, premium banner removal, and interstitial frequency. Test UMP on a registered test device with official debug geography/device settings if needed; do not ship forced geography or reset consent on every launch. No ATT/IDFA tracking prompt is introduced.

Local automated results and native build limitations are reported in the task; a passing widget test is not proof that a native ad was served. iOS requires macOS/Xcode. No store release was published.

Official references:
- https://developers.google.com/admob/flutter/quick-start
- https://developers.google.com/admob/flutter/privacy
- https://developers.google.com/admob/flutter/targeting
- https://developers.google.com/admob/flutter/rewarded

## Validation in this workspace (2026-09-08)

- `flutter test --no-pub`: 101 tests passed, including unavailable-ad navigation and no-fake-reward regressions and the existing responsive device matrix.
- Android debug APK build attempted with Flutter/Gradle, IPv4/no-daemon, and both installed usable Java runtimes. Gradle fails before compilation with `java.io.IOException: Unable to establish loopback connection` (`SocketException: Invalid argument: connect`). No new APK was produced. Repair the host Java/Windows loopback environment and rerun `flutter build apk --debug` before device testing.
- iOS build and real native test-ad display have not been verified on this Windows machine.
- `flutter analyze --no-pub`: no issues found after final lint fixes.
