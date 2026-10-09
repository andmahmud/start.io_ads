import 'package:flutter/material.dart';

import '../services/start_io_ad_service.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_panel.dart';
import 'package:startapp_sdk/startapp.dart';

class BannerAdScreen extends StatefulWidget {
  const BannerAdScreen({super.key});

  @override
  State<BannerAdScreen> createState() => _BannerAdScreenState();
}

class _BannerAdScreenState extends State<BannerAdScreen> {
  final StartIoAdService _service = StartIoAdService.instance;

  StartAppBannerAd? _bannerAd;
  bool _loading = false;
  String? _error;
  final List<String> _events = [];

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _log(String message) {
    if (!mounted) return;
    setState(() => _events.insert(0, message));
  }

  Future<void> _loadBanner() async {
    setState(() {
      _loading = true;
      _error = null;
      _bannerAd = null;
    });

    try {
      final ad = await _service.loadBanner(
        onAdImpression: () => _log('Banner: onAdImpression'),
        onAdClicked: () => _log('Banner: onAdClicked'),
      );
      if (!mounted) return;
      setState(() {
        _bannerAd = ad;
        _loading = false;
      });
      _log('Banner: loaded');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = StartIoAdService.describeError(error);
        _loading = false;
      });
      _log('Banner: failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Ad'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ScreenHeader(
            icon: Icons.view_carousel,
            title: 'Banner Ad',
            description:
                'Standard banner (320x50). Loaded once and refreshes '
                'automatically. Use "Reload Ad" to request a fresh instance.',
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            ErrorNotice(message: _error!, onRetry: _loadBanner),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _loadBanner,
            icon: const Icon(Icons.refresh),
            label: const Text('Reload Ad'),
          ),
          const SizedBox(height: 24),
          EventLogPanel(events: _events),
        ],
      ),
      bottomNavigationBar: _bannerAd == null
          ? null
          : Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SafeArea(
                top: false,
                child: Center(child: StartAppBanner(_bannerAd!)),
              ),
            ),
    );
  }
}
