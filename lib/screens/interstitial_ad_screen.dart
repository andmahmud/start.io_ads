import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

import '../services/start_io_ad_service.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_panel.dart';

class InterstitialAdScreen extends StatefulWidget {
  const InterstitialAdScreen({super.key});

  @override
  State<InterstitialAdScreen> createState() => _InterstitialAdScreenState();
}

class _InterstitialAdScreenState extends State<InterstitialAdScreen> {
  final StartIoAdService _service = StartIoAdService.instance;

  StartAppInterstitialAd? _ad;
  bool _loading = false;
  bool _showing = false;
  String? _error;
  final List<String> _events = [];

  @override
  void initState() {
    super.initState();
    _loadAndShow();
  }

  void _log(String message) {
    if (!mounted) return;
    setState(() => _events.insert(0, message));
  }

  void _cleanupAd() {
    _ad?.dispose();
    _ad = null;
  }

  /// Loads a fresh interstitial and shows it immediately once ready.
  Future<void> _loadAndShow() async {
    if (_loading || _showing) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ad = await _service.loadInterstitial(
        onAdDisplayed: () => _log('Interstitial: shown'),
        onAdNotDisplayed: () {
          _log('Interstitial: not displayed');
          _cleanupAd();
          _reloadSilently();
        },
        onAdClicked: () => _log('Interstitial: clicked'),
        onAdHidden: () {
          _log('Interstitial: closed');
          _cleanupAd();
          _reloadSilently();
        },
        onAdImpression: () => _log('Interstitial: impression'),
      );

      if (!mounted) {
        ad.dispose();
        return;
      }

      setState(() {
        _ad = ad;
        _loading = false;
      });
      _log('Interstitial: loaded');

      await _showAd();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = StartIoAdService.describeError(error);
      });
      _log('Interstitial: failed to load');
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
      // NOTE: an interstitial can be shown only once.
      _ad = null;
    });
    if (!shown) _log('Interstitial: could not be shown');
  }

  /// Reloads an interstitial in the background (no auto-show) so a fresh ad
  /// is always ready for the next test.
  Future<void> _reloadSilently() async {
    try {
      final ad = await _service.loadInterstitial(
        onAdNotDisplayed: () => _log('Interstitial: reload not displayed'),
        onAdHidden: () {
          _log('Interstitial: reload closed');
          _cleanupAd();
          _reloadSilently();
        },
        onAdClicked: () => _log('Interstitial: reload clicked'),
      );
      if (!mounted) {
        ad.dispose();
        return;
      }
      setState(() => _ad = ad);
      _log('Interstitial: reloaded (ready)');
    } catch (error) {
      if (!mounted) return;
      _log('Interstitial: background reload failed');
    }
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
        title: const Text('Interstitial Ad'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ScreenHeader(
            icon: Icons.crop_16_9,
            title: 'Interstitial Ad',
            description:
                'Full-screen ad. Each instance can be shown once; after it '
                'closes a fresh ad loads automatically for the next test.',
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
            label: Text(ready ? 'Show Interstitial' : 'Load & Show Interstitial'),
          ),
          const SizedBox(height: 24),
          EventLogPanel(events: _events),
        ],
      ),
    );
  }
}