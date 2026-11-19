import 'dart:async';

import 'package:flutter/services.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/payments/presentation/bloc/class_payment/checkout_navigation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackCheckoutView extends StatefulWidget {
  const new({
    required this.authorizationUrl,
    required this.onFinished,
    super.key,
  });

  final String authorizationUrl;
  final void Function({required bool cancelled}) onFinished;

  @override
  State<PaystackCheckoutView> createState() => _PaystackCheckoutViewState();
}

class _PaystackCheckoutViewState extends State<PaystackCheckoutView> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    unawaited(_setUp());
  }

  Future<void> _setUp() async {
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
        onNavigationRequest: _onNavigationRequest,
      ),
    );
    await _controller.loadRequest(Uri.parse(widget.authorizationUrl));
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    switch (classifyCheckoutUrl(
      request.url,
      isMainFrame: request.isMainFrame,
    )) {
      case CheckoutNavigation.stay:
        return NavigationDecision.navigate;
      case CheckoutNavigation.completed:
        _finish(cancelled: false);
      case CheckoutNavigation.cancelled:
        _finish(cancelled: true);
      case CheckoutNavigation.openExternally:
        unawaited(_openExternally(request.url));
    }
    return NavigationDecision.prevent;
  }

  Future<void> _openExternally(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return;
    }
  }

  void _finish({required bool cancelled}) {
    if (_finished) return;
    _finished = true;
    widget.onFinished(cancelled: cancelled);
  }

  Future<void> _onBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    await _confirmClose();
  }

  Future<void> _confirmClose() async {
    if (!mounted) return;
    AppHaptics.selection();
    final l10n = context.l10n;
    final close = await AppConfirmDialog.show(
      context,
      title: l10n.paymentCancelTitle,
      body: l10n.paymentCancelBody,
      cancelLabel: l10n.paymentContinuePaying,
      confirmLabel: l10n.paymentCancelConfirm,
      confirmColor: AppColors.errorRed,
    );
    if (close ?? false) _finish(cancelled: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_onBack());
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close),
            onPressed: _confirmClose,
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 16,
                color: context.colors.onSurfaceVariant,
              ),
              const Gap(AppSpacing.s8),
              Flexible(
                child: Text(
                  context.l10n.paymentCheckoutTitle,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: _progress >= 100
                ? const SizedBox(height: 2)
                : LinearProgressIndicator(
                    minHeight: 2,
                    value: _progress == 0 ? null : _progress / 100,
                  ),
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
