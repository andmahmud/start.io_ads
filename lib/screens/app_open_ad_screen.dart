import 'package:flutter/material.dart';

/// App Open (Splash) ads are NOT exposed by the current `startapp_sdk`
/// Flutter plugin. On Android they are configured natively (and disabled in
/// this demo's AndroidManifest). No fake Dart implementation is provided.
class AppOpenAdScreen extends StatelessWidget {
  const AppOpenAdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Open Ad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'App Open Ads are not supported by the current '
                    'Start.io Flutter SDK.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'What the SDK actually supports',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const _Bullet('Banner (incl. MREC and Cover)'),
            const _Bullet('Interstitial (static, video, rewarded)'),
            const _Bullet('Rewarded Video'),
            const _Bullet('Native Ads'),
            const SizedBox(height: 16),
            Text(
              'On Android, "App Open" style Splash Ads live in the native '
              'configuration. The demo disables them via the '
              'SPLASH_ADS_ENABLED provider in AndroidManifest.xml so nothing '
              'is auto-shown during tests.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}