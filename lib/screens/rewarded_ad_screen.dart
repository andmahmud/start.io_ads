import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

import '../services/start_io_ad_service.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_panel.dart';

class RewardedAdScreen extends StatefulWidget {
  const RewardedAdScreen({super.key});

  @override
  State<RewardedAdScreen> createState() => _RewardedAdScreenState();
}

class _RewardedAdScreenState extends State<RewardedAdScreen> {
  final StartIoAdService _service = StartIoAdService.instance;

  StartAppRewardedVideoAd? _ad;
  bool _loading = false;
  bool _showing = false;
  String? _error;
  int _rewards = 0;
  final List<String> _events = [];

  void _log(String message) {
    if (!mounted) return;
    setState(() => _events.insert(0, message));
  }

  void _onVideoCompleted() {
    if (!mounted) return;

    // A reward is granted ONLY after the official onVideoCompleted callback.
    // Merely loading, showing or clicking the ad never grants a reward.
    setState(() => _rewards++);
    _log('Rewarded: video completed - reward granted!');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reward earned!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      final ad = await _service.loadRewardedVideo(
        onAdDisplayed: () => _log('Rewarded: shown'),
        onAdNotDisplayed: () {
          _log('Rewarded: not displayed');
          _cleanupAd();
          _reloadSilently();
        },
        onAdClicked: () => _log('Rewarded: clicked'),
        onAdHidden: () {
          _log('Rewarded: closed');
          _cleanupAd();
          _reloadSilently();
        },
        onAdImpression: () => _log('Rewarded: impression'),
        onVideoCompleted: _onVideoCompleted,
      );

      if (!mounted) {
        ad.dispose();
        return;
      }

      setState(() {
        _ad = ad;
        _loading = false;
      });
      _log('Rewarded: loaded');

      await _showAd();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = StartIoAdService.describeError(error);
      });
      _log('Rewarded: failed to load');
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
      // NOTE: a rewarded video ad can be shown only once.
      _ad = null;
    });
    if (!shown) _log('Rewarded: could not be shown');
  }

  Future<void> _reloadSilently() async {
    try {
      final ad = await _service.loadRewardedVideo(
        onVideoCompleted: _onVideoCompleted,
        onAdNotDisplayed: () {
          _log('Rewarded: reload not displayed');
          _cleanupAd();
        },
        onAdHidden: () {
          _log('Rewarded: reload closed');
          _cleanupAd();
          _reloadSilently();
        },
        onAdClicked: () => _log('Rewarded: reload clicked'),
      );
      if (!mounted) {
        ad.dispose();
        return;
      }
      setState(() => _ad = ad);
      _log('Rewarded: reloaded (ready)');
    } catch (error) {
      if (!mounted) return;
      _log('Rewarded: background reload failed');
    }
  }

  @override
  void dispose() {
    _cleanupAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = _ad != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Ad'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rewards: $_rewards',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const ScreenHeader(
            icon: Icons.card_giftcard,
            title: 'Rewarded Ad',
            description:
                'You are rewarded ONLY after the official onVideoCompleted '
                'callback. Clicking, loading or closing early grants nothing.',
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
            label: Text(ready ? 'Show Rewarded Ad' : 'Load & Show Rewarded Ad'),
          ),
          const SizedBox(height: 24),
          EventLogPanel(events: _events),
        ],
      ),
    );
  }
}