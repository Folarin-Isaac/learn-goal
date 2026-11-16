import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/presentation/models/class_material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MaterialViewerPage extends StatelessWidget {
  const new({required this.material, super.key});

  final ClassMaterial material;

  @override
  Widget build(BuildContext context) {
    final type = material.fileType;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s16,
                AppSpacing.s8,
              ),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      material.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: context.colors.surfaceContainerHighest,
                child: switch (type) {
                  MaterialFileType.pdf => _PdfBody(url: material.url),
                  MaterialFileType.image => _ImageBody(url: material.url),
                  MaterialFileType.text => _TextBody(url: material.url),
                  _ when type.isOffice => _OfficeBody(url: material.url),
                  _ => _ViewerMessage(
                    message: context.l10n.materialViewerUnsupported,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfBody extends StatelessWidget {
  const new({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return PdfViewer.uri(
      Uri.parse(url),
      params: PdfViewerParams(
        textSelectionParams: const PdfTextSelectionParams(enabled: false),
        loadingBannerBuilder: (context, downloaded, total) => Center(
          child: CircularProgressIndicator(
            value: total == null || total == 0 ? null : downloaded / total,
          ),
        ),
        errorBannerBuilder: (context, error, stackTrace, ref) =>
            _ViewerMessage(message: context.l10n.materialViewerLoadFailed),
      ),
    );
  }
}

class _ImageBody extends StatelessWidget {
  const new({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 5,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              _ViewerMessage(message: context.l10n.materialViewerLoadFailed),
        ),
      ),
    );
  }
}

class _TextBody extends StatefulWidget {
  const new({required this.url});

  final String url;

  @override
  State<_TextBody> createState() => _TextBodyState();
}

class _TextBodyState extends State<_TextBody> {
  late final Future<String> _content = _load();

  Future<String> _load() async {
    final response = await Dio().get<String>(
      widget.url,
      options: Options(responseType: ResponseType.plain),
    );
    return response.data ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _content,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ViewerMessage(message: context.l10n.materialViewerLoadFailed);
        }
        final text = snapshot.data;
        if (text == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              text,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OfficeBody extends StatefulWidget {
  const new({required this.url});

  final String url;

  @override
  State<_OfficeBody> createState() => _OfficeBodyState();
}

class _OfficeBodyState extends State<_OfficeBody> {
  static const String _viewerHost = 'view.officeapps.live.com';

  late final Uri _viewerUri = Uri.https(_viewerHost, '/op/embed.aspx', {
    'src': widget.url,
  });
  final WebViewController _controller = WebViewController();
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          final allowed = !request.isMainFrame || uri?.host == _viewerHost;
          return allowed
              ? NavigationDecision.navigate
              : NavigationDecision.prevent;
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? false) {
            if (mounted) setState(() => _failed = true);
          }
        },
      ),
    );
    await _controller.loadRequest(_viewerUri);
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _ViewerMessage(message: context.l10n.materialViewerLoadFailed);
    }
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ViewerMessage extends StatelessWidget {
  const new({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
