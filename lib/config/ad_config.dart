/// Central PRODUCTION configuration for the Start.io Ads Demo.
///
/// The Start.io App ID below is the real production App ID from the
/// Start.io Portal (My Apps -> your app -> App ID).
library;
const String startIoAppId = '209260010';

/// Ad tags only LABEL a placement inside your app so the Start.io dashboard
/// can report per-placement revenue. They are optional and do NOT replace the
/// App ID: `startapp_sdk` (v1.0.1) does not require any per-format placement /
/// ad-unit IDs, all formats are served using [startIoAppId] alone.
class AdConfig {
  AdConfig._();

  /// The production App ID is consumed NATIVELY (not from Dart at runtime):
  ///
  ///   Android -> android/app/src/main/AndroidManifest.xml
  ///              `meta-data` `android:name="com.startapp.sdk.APPLICATION_ID"`
  ///
  ///   iOS     -> ios/Runner/Info.plist
  ///              `key` `com.startapp.sdk.APPLICATION_ID`
  static const String androidAppId = startIoAppId;
  static const String iosAppId = startIoAppId;

  // ---------------------------------------------------------------------------
  // AD TAGS (optional placement labels for dashboard reporting)
  // ---------------------------------------------------------------------------
  static const String bannerAdTag = 'banner';
  static const String mrecAdTag = 'mrec';
  static const String interstitialAdTag = 'interstitial';
  static const String rewardedAdTag = 'rewarded_video';
  static const String nativeAdTag = 'native';
  static const String videoAdTag = 'video';

  // ---------------------------------------------------------------------------
  // SUPPORTED FORMATS (startapp_sdk v1.0.1)
  // ---------------------------------------------------------------------------
  // The official Flutter plugin supports:
  //   - Banner (incl. MREC and Cover)
  //   - Interstitial (static, video and rewarded-video interstitials)
  //   - Rewarded Video
  //   - Native
  //
  // There is NO dedicated "Video" API and NO "App Open" API in the plugin.
  //   * Video ads are delivered through Interstitial/Rewarded Video; the demo
  //     exposes the official `StartAppInterstitialAdMode.video`.
  //   * App Open / Splash ads are controlled natively and are disabled here.
}