# Start.io Ads Demo (Flutter)

A clean, material-design demo app for exercising **Start.io** ad formats from a
single Home Screen. It is configured with the **production App ID `209260010`**
and runs the SDK in **Production Mode** (test mode is intentionally removed).

```
┌──────────────────────────────┐
│        Start.io Ads Demo     │
│  Test different ad formats  │
├──────────────────────────────┤
│  SDK Status: Initialized     │
│  Production Mode: Active     │
│                              │
│  [ 📢 Banner Ad ]            │
│  [ ⛶ Interstitial Ad ]       │
│  [ 🎁 Rewarded Ad ]          │
│  [ 📰 Native Ad ]            │
│  [ ▶ Video Ad ]              │
│  [ ⟶ App Open Ad ]           │
│  [ ▶ Show All Ads Test ]     │
└──────────────────────────────┘
```

## Supported formats

Verified against the official plugin **`startapp_sdk` 1.0.1** (Flutter / Dart):

| Format          | Supported | How it is tested here                                  |
| --------------- | :-------: | ------------------------------------------------------ |
| Banner (320×50) | ✅         | `Banner Ad` screen, auto-loaded, "Reload Ad" button    |
| MREC / Cover    | ✅         | Supported by the SDK (`StartAppBannerType`)            |
| Interstitial    | ✅         | `Interstitial Ad` screen with full lifecycle logs      |
| Rewarded Video  | ✅         | `Rewarded Ad` screen, reward only on `onVideoCompleted` |
| Native          | ✅         | `Native Ad` screen with a custom layout                |
| Video           | ⚠️ partial  | No dedicated API — served via interstitial (`StartAppInterstitialAdMode.video`) / rewarded |
| App Open        | ❌         | Not exposed by the Flutter SDK — screen explains why   |

> There is **no fake implementation** of unsupported formats and **no invented
> ad-unit IDs**. The Start.io Flutter SDK addresses every format with the App ID
> alone; ad tags are optional dashboard labels only. The `App Open Ad` screen
> clearly states the format is not supported by the current SDK, and the
> `Video Ad` screen uses the official video-interstitial API instead.

---

## 1. Prerequisites

- Flutter **3.x** (project generated with Flutter 3.47 / Dart 3.13).
- Android Studio / a device or emulator (API 21+).
- A Start.io account → [portal.start.io](https://portal.start.io) (the App ID
  `209260010` below was created there).

## 2. Install dependencies

```sh
flutter pub get
```

The only external dependency is:

```yaml
dependencies:
  startapp_sdk: ^1.0.1
```

## 3. Start.io configuration (PRODUCTION)

The App ID is read **natively** by the SDK (never passed from Dart). It is
already set to the real production App ID:

### Android `android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.startapp.sdk.APPLICATION_ID"
    android:value="209260010" />
```

Permissions already added:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="com.google.android.gms.permission.AD_ID" />
```

Return Ads and automatic Splash ("App Open") ads are disabled so every ad is
shown only on an explicit user action:

```xml
<meta-data android:name="com.startapp.sdk.RETURN_ADS_ENABLED" android:value="false" />
<provider
    android:authorities="com.startapp.flutter.sdk.${applicationId}"
    android:name="com.startapp.flutter.sdk.StartAppFlutterHelper"
    android:exported="false">
    <meta-data android:name="com.startapp.sdk.SPLASH_ADS_ENABLED" android:value="false" />
</provider>
```

### iOS `ios/Runner/Info.plist`

```xml
<key>com.startapp.sdk.APPLICATION_ID</key>
<string>209260010</string>
```

### Gradle note (important)

`com.startapp:inapp-sdk` (5.4.0, pulled in by the plugin) requires
**compileSdk 36**, while the plugin module declares 34. The root
`android/build.gradle.kts` already contains an override that bumps every
Android library subproject to `compileSdk 36`, so no further action is needed.
If you move this code, make sure to keep that block.

## 4. Where the configuration lives

Everything Dart-side lives in **`lib/config/ad_config.dart`**:

```dart
const String startIoAppId = '209260010';   // production App ID

class AdConfig {
  static const String bannerAdTag = 'banner';
  static const String interstitialAdTag = 'interstitial';
  static const String rewardedAdTag = 'rewarded_video';
  static const String nativeAdTag = 'native';
  static const String videoAdTag = 'video';
}
```

- **App ID** → native files (`AndroidManifest.xml`, `Info.plist`), mirrored in
  `ad_config.dart` for documentation.
- **Ad tags** → `ad_config.dart`. Optional labels only; Start.io does **not**
  require per-format placement/ad-unit IDs for the Flutter SDK.

All loading goes through the reusable **`lib/services/start_io_ad_service.dart`**
singleton (`StartAppSdk` is a singleton; test ads are never enabled —
production mode).

## 5. Run the app

```sh
flutter run                # pick an attached device/emulator
# or
flutter run -d <deviceId>
```

Run static analysis and the widget tests:

```sh
flutter analyze
flutter test
```

## 6. Production build

```sh
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

> ⚠️ Verify on your Start.io dashboard that the App ID is `209260010` and that
> impressions/revenue only ever come from real users navigating the app.

## 7. How to test each ad format

1. **Banner** — opens the `Banner Ad` screen, loads a 320×50 banner at the
   bottom, shows a spinner while loading and a friendly message on failure.
   Use **Reload Ad** to request a new instance.
2. **Interstitial** — `Load & Show` loads then displays the full-screen
   interstitial. Events (loaded, shown, clicked, closed, impression, not
   displayed) are logged live; after it closes a fresh ad is pre-loaded.
3. **Rewarded** — watch the video to completion. Only the official
   `onVideoCompleted` callback grants a reward. The **Rewards** counter only
   increments then, and a `Reward earned!` message is shown.
4. **Native** — the native ad is rendered with your own layout (title,
   description, image/icon, CTA, rating, installs, category). Do **not** attach
   your own tap handlers to ad widgets — clicks are handled by the native view.
5. **Video** — the plugin has no dedicated "Video" API, so this screen tests a
   video **interstitial** via `StartAppInterstitialAdMode.video`. Use the
   Rewarded screen for a video with a reward.
6. **App Open** — not supported by the current Flutter SDK. The screen says so
   explicitly instead of faking it.
7. **Show All Ads Test** — runs Banner, Native, Interstitial and Rewarded in
   sequence with a live checklist.

## 8. IMPORTANT: invalid traffic / self-clicking warning

- This demo exists to **verify SDK behaviour**, not to inflate metrics.
- **Never repeatedly click your own ads.** Self-clicks and artificial traffic
  violate Start.io's policies and can lead to account suspension.
- **Never generate impressions/clicks in a loop** — production or not.
- Reward logic grants a reward **only** on the rewarded-video completion
  callback — there is no code path that grants rewards for clicks or load.

## Project layout

```
lib/
├── main.dart                        # entry point + Material 3 theme
├── config/
│   └── ad_config.dart               # production App ID + ad tags
├── services/
│   └── start_io_ad_service.dart     # StartAppSdk singleton wrapper + errors
├── screens/
│   ├── splash_screen.dart           # branded intro splash
│   ├── main_shell.dart              # bottom-nav shell (Ad Tests / Status / About)
│   ├── home_screen.dart
│   ├── banner_ad_screen.dart
│   ├── interstitial_ad_screen.dart
│   ├── rewarded_ad_screen.dart
│   ├── native_ad_screen.dart
│   ├── video_ad_screen.dart
│   ├── app_open_ad_screen.dart
│   └── show_all_ads_screen.dart
└── widgets/
    ├── ad_test_button.dart
    ├── screen_header.dart
    └── status_panel.dart
```

## Official references

- Start.io Flutter plugin: https://github.com/StartApp-SDK/flutter-plugin
- Pub package: https://pub.dev/packages/startapp_sdk
- API docs: https://pub.dev/documentation/startapp_sdk/latest/
- Start.io docs: https://support.start.io/