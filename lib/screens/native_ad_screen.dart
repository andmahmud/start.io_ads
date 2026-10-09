import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

import '../services/start_io_ad_service.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_panel.dart';

class NativeAdScreen extends StatefulWidget {
  const NativeAdScreen({super.key});

  @override
  State<NativeAdScreen> createState() => _NativeAdScreenState();
}

class _NativeAdScreenState extends State<NativeAdScreen> {
  final StartIoAdService _service = StartIoAdService.instance;

  StartAppNativeAd? _nativeAd;
  bool _loading = false;
  String? _error;
  final List<String> _events = [];

  @override
  void initState() {
    super.initState();
    _loadNative();
  }

  void _log(String message) {
    if (!mounted) return;
    setState(() => _events.insert(0, message));
  }

  Future<void> _loadNative() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ad = await _service.loadNative(
        onAdImpression: () => _log('Native: impression'),
        onAdClicked: () => _log('Native: clicked'),
      );
      if (!mounted) {
        ad.dispose();
        return;
      }
      setState(() {
        _nativeAd = ad;
        _loading = false;
      });
      _log('Native: loaded');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = StartIoAdService.describeError(error);
        _loading = false;
      });
      _log('Native: failed to load');
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nativeAd = _nativeAd;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Ad'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ScreenHeader(
            icon: Icons.article,
            title: 'Native Ad',
            description:
                'Rendered with your own widgets. Tap handling is left to the '
                'underlying native view (never intercept clicks on ad widgets).',
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            ErrorNotice(message: _error!, onRetry: _loadNative),
          if (_error == null && nativeAd != null) ...[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              // The ad is visually separated from the rest of the UI.
              child: StartAppNative(
                nativeAd,
                (context, setState, ad) => _NativeAdLayout(ad: ad),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Note: this demo renders only fields exposed by the official '
              'plugin (no dedicated "advertiser" field; nativeAd.title is the '
              'main ad line).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (nativeAd != null || _error != null)
            FilledButton.icon(
              onPressed: _loading ? null : _loadNative,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload Ad'),
            ),
          const SizedBox(height: 24),
          EventLogPanel(events: _events),
        ],
      ),
    );
  }
}

class _NativeAdLayout extends StatelessWidget {
  const _NativeAdLayout({required this.ad});

  final StartAppNativeAd ad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _AdImage(
                  url: ad.imageUrl,
                  width: 88,
                  height: 88,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title ?? 'No title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (ad.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            ad.rating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                    if (ad.installs != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${ad.installs} installs',
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
          const SizedBox(height: 12),
          Text(
            ad.description ?? 'No description',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (ad.category != null) ...[
            const SizedBox(height: 8),
            Text(
              'Category: ${ad.category}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (ad.secondaryImageUrl != null) ...[
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _AdImage(url: ad.secondaryImageUrl),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // IMPORTANT: Do not attach your own onTap handlers to ad widgets.
          // Clicks are handled by the underlying platform view (ignorePointer).
          FilledButton(
            onPressed: null,
            child: Text(ad.callToAction ?? 'Install'),
          ),
        ],
      ),
    );
  }
}

class _AdImage extends StatelessWidget {
  const _AdImage({this.url, this.width, this.height});

  final String? url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );

    if (url == null || url!.isEmpty) return placeholder;

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : SizedBox(
                width: width,
                height: height,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
      },
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}