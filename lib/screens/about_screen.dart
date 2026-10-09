import 'package:flutter/material.dart';

import '../services/start_io_ad_service.dart';

/// About / branding screen (bottom-nav "About" tab).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = StartIoAdService.instance;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Start.io Ads',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Version 1.0.0 · Start.io SDK ${service.sdkVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Chip(
                avatar: const Icon(
                  Icons.verified_user,
                  size: 18,
                  color: Color(0xFF00A86B),
                ),
                label: const Text('Production Mode: Active'),
                backgroundColor: theme.colorScheme.secondaryContainer,
                side: BorderSide.none,
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              icon: Icons.view_carousel,
              title: 'Purpose',
              body:
                  'A development-only Flutter app that lets you test every '
                  'Start.io ad format supported by the official plugin: Banner, '
                  'Interstitial, Rewarded Video, Native (plus video '
                  'interstitials via the official mode API).',
            ),
            _Section(
              icon: Icons.auto_awesome,
              title: 'No fake SDK APIs',
              body:
                  'Unsupported formats are clearly reported instead of '
                  'implemented with invented classes: there is no dedicated '
                  '"Video" or "App Open" API in startapp_sdk, so those screens '
                  'explain it and reuse the real API.',
            ),
            _Section(
              icon: Icons.link,
              title: 'References',
              body:
                  'Plugin: github.com/StartApp-SDK/flutter-plugin\n'
                  'Package: pub.dev/packages/startapp_sdk\n'
                  'Docs: support.start.io',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}