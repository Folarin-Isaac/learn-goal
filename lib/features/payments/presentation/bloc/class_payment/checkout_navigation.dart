enum CheckoutNavigation { stay, completed, cancelled, openExternally }

CheckoutNavigation classifyCheckoutUrl(
  String url, {
  required bool isMainFrame,
}) {
  final uri = Uri.tryParse(url);
  if (uri == null) return CheckoutNavigation.stay;
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') {
    const inPage = {'about', 'data', 'blob', 'javascript', ''};
    return inPage.contains(scheme)
        ? CheckoutNavigation.stay
        : CheckoutNavigation.openExternally;
  }
  if (!isMainFrame) return CheckoutNavigation.stay;
  final host = uri.host.toLowerCase();
  final isPaystack =
      _isUnder(host, 'paystack.com') || _isUnder(host, 'paystack.co');
  if (isPaystack) {
    return host == 'standard.paystack.co' && uri.path.startsWith('/close')
        ? CheckoutNavigation.cancelled
        : CheckoutNavigation.stay;
  }
  final query = uri.queryParameters;
  if (query.containsKey('trxref') || query.containsKey('reference')) {
    return CheckoutNavigation.completed;
  }
  return CheckoutNavigation.stay;
}

bool _isUnder(String host, String domain) =>
    host == domain || host.endsWith('.$domain');
