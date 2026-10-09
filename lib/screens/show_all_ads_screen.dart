import 'dart:async';

import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

import '../services/start_io_ad_service.dart';
import '../widgets/screen_header.dart';

enum _StepStatus { pending, running, success, failed }

class _Step {
  _Step(this.title, this.icon);

  final String title;
  final IconData icon;
  _StepStatus status = _StepStatus.pending;
  String detail = '';
}

class ShowAllAdsScreen extends StatefulWidget {
  const ShowAllAdsScreen({super.key});

  @override
  State<ShowAllAdsScreen> createState() => _ShowAllAdsScreenState();
}

class _ShowAllAdsScreenState extends State<ShowAllAdsScreen> {
  final StartIoAdService _service = StartIoAdService.instance;
  final List<_Step> _steps = [
    _Step('Banner', Icons.view_carousel),
    _Step('Native', Icons.article),
    _Step('Interstitial', Icons.crop_16_9),
    _Step('Rewarded Video', Icons.card_giftcard),
  ];

  StartAppBannerAd? _bannerAd;
  StartAppNativeAd? _nativeAd;
  bool _running = false;

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_running) return;

    setState(() {
      _running = true;
      for (final step in _steps) {
        step.status = _StepStatus.pending;
        step.detail = '';
      }
    });

    // 1. Banner ------------------------------------------------------------
    _start(0);
    try {
      final ad = await _service.loadBanner(
        onAdImpression: () => debugPrint('ShowAll: banner impression'),
        onAdClicked: () => debugPrint('ShowAll: banner clicked'),
      );
      if (!mounted) {
        ad.dispose();
        return;
      }
      setState(() => _bannerAd = ad);
      _finish(0, true, 'Loaded & displayed');
    } catch (error) {
      _finish(0, false, StartIoAdService.describeError(error));
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    // 2. Native ------------------------------------------------------------
    _start(1);
    try {
      final ad = await _service.loadNative(
        onAdImpression: () => debugPrint('ShowAll: native impression'),
        onAdClicked: () => debugPrint('ShowAll: native clicked'),
      );
      if (!mounted) {
        ad.dispose();
        return;
      }
      setState(() => _nativeAd = ad);
      _finish(1, true, 'Loaded & displayed');
    } catch (error) {
      _finish(1, false, StartIoAdService.describeError(error));
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    // 3. Interstitial ------------------------------------------------------
    _start(2);
    await _runInterstitial();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    // 4. Rewarded video ----------------------------------------------------
    _start(3);
    await _runRewarded();

    setState(() => _running = false);
    if (!mounted) return;

    final failed =
        _steps.where((s) => s.status == _StepStatus.failed).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed == 0
              ? 'All ad formats tested successfully.'
              : '$failed format(s) failed. Check the list above.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _runInterstitial() async {
    final completer = Completer<void>();

    try {
      final ad = await _service.loadInterstitial(
        onAdNotDisplayed: () {
          if (!completer.isCompleted) completer.complete();
        },
        onAdHidden: () {
          if (!completer.isCompleted) completer.complete();
        },
        onAdClicked: () => debugPrint('ShowAll: interstitial clicked'),
      );

      final shown = await ad.show();
      if (shown) {
        await completer.future
            .timeout(const Duration(seconds: 30), onTimeout: () {});
      } else {
        if (!completer.isCompleted) completer.complete();
      }
      ad.dispose();
      _finish(2, true, 'Shown & closed');
    } catch (error) {
      _finish(2, false, StartIoAdService.describeError(error));
    }
  }

  Future<void> _runRewarded() async {
    final completer = Completer<void>();
    var rewardGranted = false;

    try {
      final ad = await _service.loadRewardedVideo(
        onVideoCompleted: () {
          rewardGranted = true;
          if (!completer.isCompleted) completer.complete();
        },
        onAdNotDisplayed: () {
          if (!completer.isCompleted) completer.complete();
        },
        onAdHidden: () {
          if (!completer.isCompleted) completer.complete();
        },
      );

      final shown = await ad.show();
      if (shown) {
        await completer.future
            .timeout(const Duration(seconds: 30), onTimeout: () {});
      } else {
        if (!completer.isCompleted) completer.complete();
      }
      ad.dispose();
      _finish(3, true, rewardGranted ? 'Video completed, reward granted' : 'Shown & closed');
    } catch (error) {
      _finish(3, false, StartIoAdService.describeError(error));
    }
  }

  void _start(int index) {
    if (!mounted) return;
    setState(() {
      _steps[index].status = _StepStatus.running;
      _steps[index].detail = 'Running...';
    });
  }

  void _finish(int index, bool ok, String detail) {
    if (!mounted) return;
    setState(() {
      _steps[index].status = ok ? _StepStatus.success : _StepStatus.failed;
      _steps[index].detail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Show All Ads Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ScreenHeader(
            icon: Icons.playlist_play,
            title: 'Show All Ads Test',
            description:
                'Banner and Native stay loaded on screen while the full-screen '
                'formats run one after another. Watch each step below.',
          ),
          const SizedBox(height: 20),
          for (final step in _steps) _StepCard(step: step),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: const Icon(Icons.playlist_play),
            label: Text(_running ? 'Running...' : 'Start Full Test'),
          ),
          const SizedBox(height: 24),
          if (_bannerAd != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: StartAppBanner(_bannerAd!),
            ),
          if (_nativeAd != null) ...[
            const SizedBox(height: 16),
            Text(
              'Native ad preview:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: StartAppNative(
                _nativeAd!,
                (context, setState, ad) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (ad.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            ad.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox(
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title ?? 'No title',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ad.description ?? 'No description',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ad.callToAction ?? 'Install',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (Color color, IconData icon) = switch (step.status) {
      _StepStatus.pending => (
          theme.colorScheme.outline,
          Icons.radio_button_unchecked,
        ),
      _StepStatus.running => (
          theme.colorScheme.primary,
          Icons.sync,
        ),
      _StepStatus.success => (
          const Color(0xFF00A86B),
          Icons.check_circle,
        ),
      _StepStatus.failed => (
          theme.colorScheme.error,
          Icons.cancel,
        ),
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(step.icon,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        step.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (step.detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}