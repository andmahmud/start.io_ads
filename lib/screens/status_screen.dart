import 'package:flutter/material.dart';

import '../config/ad_config.dart';
import '../services/start_io_ad_service.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_panel.dart';
import 'show_all_ads_screen.dart';

/// SDK / configuration status screen (bottom-nav "Status" tab).
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = StartIoAdService.instance;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            const ScreenHeader(
              icon: Icons.monitor_heart_outlined,
              title: 'Status',
              description: 'SDK initialization and configuration summary',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start.io SDK',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusTile(
                    label: 'SDK Status:',
                    value: service.isInitialized ? 'Initialized' : 'Not initialized',
                    icon: service.isInitialized
                        ? Icons.check_circle
                        : Icons.error_outline,
                    color: service.isInitialized
                        ? const Color(0xFF00A86B)
                        : theme.colorScheme.error,
                  ),
                  StatusTile(
                    label: 'Production Mode:',
                    value: 'Active',
                    icon: Icons.verified_user,
                    color: const Color(0xFF00A86B),
                  ),
                  StatusTile(
                    label: 'SDK Version:',
                    value: service.sdkVersion,
                    icon: Icons.memory,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusTile(
                    label: 'App ID (native):',
                    value: 'AndroidManifest / Info.plist',
                    icon: Icons.key,
                  ),
                  StatusTile(
                    label: 'Banner tag:',
                    value: AdConfig.bannerAdTag,
                    icon: Icons.sell_outlined,
                  ),
                  StatusTile(
                    label: 'Interstitial tag:',
                    value: AdConfig.interstitialAdTag,
                    icon: Icons.sell_outlined,
                  ),
                  StatusTile(
                    label: 'Rewarded tag:',
                    value: AdConfig.rewardedAdTag,
                    icon: Icons.sell_outlined,
                  ),
                  StatusTile(
                    label: 'Native tag:',
                    value: AdConfig.nativeAdTag,
                    icon: Icons.sell_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This build uses the real production App ID '
                      '(209260010). Ads load only on natural user '
                      'navigation - never auto-click, repeat triggers, or fake '
                      'impressions/clicks.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ShowAllAdsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.playlist_play),
              label: const Text('Run Show All Ads Test'),
            ),
          ],
        ),
      ),
    );
  }
}