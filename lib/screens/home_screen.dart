import 'package:flutter/material.dart';

import '../services/start_io_ad_service.dart';
import '../widgets/ad_test_button.dart';
import 'app_open_ad_screen.dart';
import 'banner_ad_screen.dart';
import 'interstitial_ad_screen.dart';
import 'native_ad_screen.dart';
import 'rewarded_ad_screen.dart';
import 'show_all_ads_screen.dart';
import 'video_ad_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const _HeroHeader(),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Ad formats',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'PRODUCTION MODE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF00A86B),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AdTestButton(
              icon: Icons.view_carousel,
              title: 'Banner Ad',
              subtitle: 'Standard 320x50 banner at the bottom',
              onTap: () => _open(context, const BannerAdScreen()),
            ),
            AdTestButton(
              icon: Icons.crop_16_9,
              title: 'Interstitial Ad',
              subtitle: 'Full-screen static / video interstitial',
              accent: const Color(0xFF7C4DFF),
              onTap: () => _open(context, const InterstitialAdScreen()),
            ),
            AdTestButton(
              icon: Icons.card_giftcard,
              title: 'Rewarded Ad',
              subtitle: 'Watch a rewarded video and earn a reward',
              accent: const Color(0xFF00A86B),
              onTap: () => _open(context, const RewardedAdScreen()),
            ),
            AdTestButton(
              icon: Icons.article,
              title: 'Native Ad',
              subtitle: 'Native ad rendered with your own layout',
              accent: const Color(0xFFFF6D00),
              onTap: () => _open(context, const NativeAdScreen()),
            ),
            AdTestButton(
              icon: Icons.play_circle_outline,
              title: 'Video Ad',
              subtitle: 'Test a video interstitial (official API)',
              accent: const Color(0xFF00838F),
              onTap: () => _open(context, const VideoAdScreen()),
            ),
            AdTestButton(
              icon: Icons.open_in_new,
              title: 'App Open Ad',
              subtitle: 'Check native App Open support',
              accent: const Color(0xFF546E7A),
              badge: 'Unsupported',
              onTap: () => _open(context, const AppOpenAdScreen()),
            ),
            const SizedBox(height: 12),
            AdTestButton(
              icon: Icons.playlist_play,
              title: 'Show All Ads Test',
              subtitle: 'Run every supported format in sequence',
              accent: theme.colorScheme.primary,
              onTap: () => _open(context, const ShowAllAdsScreen()),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is a production integration demo. Ads must only '
                      'load on natural user navigation - never auto-click, '
                      'repeat triggers, or fake impressions/clicks.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = StartIoAdService.instance;
    final initialized = service.isInitialized;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B6CFF), Color(0xFF3343C9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D5AFE).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start.io Ads',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Test different Start.io advertisement formats',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeroChip(
                icon: initialized
                    ? Icons.check_circle
                    : Icons.error_outline,
                label: initialized ? 'SDK Initialized' : 'SDK Pending',
                value: initialized ? 'v${service.sdkVersion}' : '...',
                color: initialized ? const Color(0xFF4CD97B) : Colors.white54,
              ),
              const SizedBox(width: 10),
              _HeroChip(
                icon: Icons.verified_user,
                label: 'Production Mode',
                value: 'Active',
                color: const Color(0xFF4CD97B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}