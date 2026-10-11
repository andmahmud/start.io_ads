import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:startapp_sdk/startapp.dart';

import '../config/ad_config.dart';

/// Thin, reusable wrapper around the official Start.io `StartAppSdk`.
///
/// The rest of the app never talks to the SDK directly; it goes through this
/// service so that initialization and error handling live in one place.
///
/// The App ID itself is read natively (AndroidManifest.xml / Info.plist) by
/// the Start.io SDK - see [AdConfig.startIoAppId]. The SDK runs in PRODUCTION
/// mode: no test-ads flag is ever set in this codebase.
class StartIoAdService {
  StartIoAdService._();

  /// App-wide singleton.
  static final StartIoAdService instance = StartIoAdService._();

  final StartAppSdk _sdk = StartAppSdk();

  bool _initialized = false;
  String _sdkVersion = 'unknown';

  bool get isInitialized => _initialized;
  String get sdkVersion => _sdkVersion;

  /// Reads the native SDK version. The SDK initializes in production mode;
  /// no test-ads flag is ever set in this codebase.
  ///
  /// Safe to call multiple times; it is a no-op after the first success.
  Future<void> init() async {
    if (_initialized) return;

    try {
      _sdkVersion = await _sdk.getSdkVersion();
    } catch (error) {
      debugPrint('Start.io: failed to read SDK version: $error');
      _sdkVersion = 'unknown';
    }

    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // BANNER (also MREC / COVER)
  // ---------------------------------------------------------------------------
  Future<StartAppBannerAd> loadBanner({
    StartAppBannerType type = StartAppBannerType.BANNER,
    String adTag = AdConfig.bannerAdTag,
    VoidCallback? onAdImpression,
    VoidCallback? onAdClicked,
  }) {
    return _sdk.loadBannerAd(
      type,
      prefs: StartAppAdPreferences(adTag: adTag),
      onAdImpression: onAdImpression,
      onAdClicked: onAdClicked,
    );
  }

  // ---------------------------------------------------------------------------
  // INTERSTITIAL (static or video)
  // ---------------------------------------------------------------------------
  Future<StartAppInterstitialAd> loadInterstitial({
    StartAppInterstitialAdMode mode = StartAppInterstitialAdMode.automatic,
    String adTag = AdConfig.interstitialAdTag,
    VoidCallback? onAdDisplayed,
    VoidCallback? onAdNotDisplayed,
    VoidCallback? onAdClicked,
    VoidCallback? onAdHidden,
    VoidCallback? onAdImpression,
  }) {
    return _sdk.loadInterstitialAd(
      mode: mode,
      prefs: StartAppAdPreferences(adTag: adTag),
      onAdDisplayed: onAdDisplayed,
      onAdNotDisplayed: onAdNotDisplayed,
      onAdClicked: onAdClicked,
      onAdHidden: onAdHidden,
      onAdImpression: onAdImpression,
    );
  }

  // ---------------------------------------------------------------------------
  // REWARDED VIDEO
  // ---------------------------------------------------------------------------
  Future<StartAppRewardedVideoAd> loadRewardedVideo({
    String adTag = AdConfig.rewardedAdTag,
    VoidCallback? onAdDisplayed,
    VoidCallback? onAdNotDisplayed,
    VoidCallback? onAdClicked,
    VoidCallback? onAdHidden,
    VoidCallback? onAdImpression,
    VoidCallback? onVideoCompleted,
  }) {
    return _sdk.loadRewardedVideoAd(
      prefs: StartAppAdPreferences(adTag: adTag),
      onAdDisplayed: onAdDisplayed,
      onAdNotDisplayed: onAdNotDisplayed,
      onAdClicked: onAdClicked,
      onAdHidden: onAdHidden,
      onAdImpression: onAdImpression,
      onVideoCompleted: onVideoCompleted,
    );
  }

  // ---------------------------------------------------------------------------
  // NATIVE
  // ---------------------------------------------------------------------------
  Future<StartAppNativeAd> loadNative({
    String adTag = AdConfig.nativeAdTag,
    VoidCallback? onAdImpression,
    VoidCallback? onAdClicked,
  }) {
    return _sdk.loadNativeAd(
      prefs: StartAppAdPreferences(adTag: adTag),
      onAdImpression: onAdImpression,
      onAdClicked: onAdClicked,
    );
  }

  /// User-friendly message shown when Start.io reports that no ad is
  /// available right now.
  static const String noFillMessage =
      'No ad available right now. Please try again later.';

  /// User-friendly message shown when the failure is an actual network or
  /// connectivity problem.
  static const String networkMessage =
      'Please check your internet connection and try again.';

  /// Fallback message for any other SDK/ad failure.
  static const String genericMessage = 'Unable to load ad. Please try again.';

  /// Turns any thrown error into a short, classified message suitable for the
  /// UI. The real SDK error is appended as a `Details:` line so it stays
  /// visible for debugging.
  static String describeError(Object error) {
    final code = error is PlatformException ? error.code.toLowerCase() : '';
    final message = _errorMessage(error).toLowerCase();

    String text;
    if (_isNoFill(code, message)) {
      text = noFillMessage;
    } else if (_isConnectivity(code, message)) {
      text = networkMessage;
    } else {
      text = genericMessage;
    }
    return '$text\nDetails: $error';
  }

  static String _errorMessage(Object error) {
    if (error is PlatformException) {
      return error.message?.toString() ?? '';
    }
    if (error is StartAppException) {
      return error.message?.toString() ?? '';
    }
    return error.toString();
  }

  static bool _isNoFill(String code, String message) {
    return code.contains('no_fill') ||
        message.contains('no fill') ||
        message.contains('status 204') ||
        message.contains('204 no content') ||
        message.contains('empty response');
  }

  static bool _isConnectivity(String code, String message) {
    return code.contains('network') ||
        code.contains('connection') ||
        message.contains('internet') ||
        message.contains('network') ||
        message.contains('connectivity') ||
        message.contains('socket') ||
        message.contains('unknownhost') ||
        message.contains('unreachable') ||
        message.contains('no route to host') ||
        message.contains('refused') ||
        message.contains('resolve host');
  }
}
