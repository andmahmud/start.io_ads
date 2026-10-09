import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

import '../services/start_io_ad_service.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_panel.dart';
import 'rewarded_ad_screen.dart';

/// The official `startapp_sdk` plugin does NOT expose a dedicated "Video Ad"
/// format. Video ads are served through:
///   * Interstitial ads with `StartAppInterstitialAdMode.video`
///   * Rewarded videos (`StartAppRewardedVideoAd`)
///
/// So instead of inventing a fake API, this screen uses the real, supported
/// one: a video interstitial.
class VideoAdScreen extends StatefulWidget {
  const VideoAdScreen({super.key});

  @override
  State<VideoAdScreen> createState() => _VideoAdScreenState();
}

class _VideoAdScreenState extends State<VideoAdScreen> {
  final StartIoAdService _service = StartIoAdService.instance;

  StartAppInterstitialAd? _ad;
  bool _loading = false;
  bool _showing = false;
  String? _error;
  final List<String> _events = [];

  void _log(String message) {
    if (!mounted) return;
    setState(() => _events.insert(0, message));
  }

  void _cleanupAd() {
    _ad?.dispose();
    _ad = null;
  }

  Future<void> _loadAndShow() async {
    if (_loading || _showing) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ad = await _service.loadInterstitial(
        // Official API: request a video interstitial.
        mode: StartAppInterstitialAdMode.video,
        onAdDisplayed: () => _log('Video interstitial: shown'),
        onAdNotDisplayed: () {
          _log('Video interstitial: not displayed');
          _cleanupAd();
        },
        onAdClicked: () => _log('Video interstitial: clicked'),
        onAdHidden: () {
          _log('Video interstitial: closed');
          _cleanupAd();
        },
        onAdImpression: () => _log('Video interstitial: impression'),
      );

      if (!mounted) {
        ad.dispose();
        return;
      }

      setState(() {
        _ad = ad;
        _loading = false;
      });
      _log('Video interstitial: loaded');

      await _showAd();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = StartIoAdService.describeError(error);
      });
      _log('Video interstitial: failed to load');
    }
  }

  Future<void> _showAd() async {
    final ad = _ad;
    if (ad == null) return;

    setState(() => _showing = true);
    final shown = await ad.show();
    if (!mounted) return;
    setState(() {
      _showing = false;
      _ad = null;
    });
    if (!shown) _log('Video interstitial: could not be shown');
  }

  @override
  void dispose() {
    _cleanupAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _ad != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Ad'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ScreenHeader(
            icon: Icons.play_circle_outline,
            title: 'Video Ad',
            description:
                'The startapp_sdk plugin ships no separate video API, so this '
                'tests a video interstitial using the official '
                'StartAppInterstitialAdMode.video. Rewarded video lives in the '
                'Rewarded Ad screen.',
          ),
          const SizedBox(height: 20),
          if (_loading || _showing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            ErrorNotice(message: _error!, onRetry: _loadAndShow),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed:
                (_loading || _showing) ? null : (ready ? _showAd : _loadAndShow),
            icon: Icon(ready ? Icons.play_arrow : Icons.download),
            label: Text(ready ? 'Show Video Ad' : 'Load & Show Video Ad'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RewardedAdScreen(),
                ),
              );
            },
            icon: const Icon(Icons.card_giftcard),
            label: const Text('Test Rewarded Video instead'),
          ),
          const SizedBox(height: 24),
          EventLogPanel(
            title: 'Video interstitial events',
            events: _events,
          ),
        ],
      ),
    );
  }
}