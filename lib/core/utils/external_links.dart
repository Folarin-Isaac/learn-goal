import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalUrl(String url) async {
  var value = url.trim();
  if (value.isEmpty) return false;
  if (!value.contains('://')) value = 'https://$value';
  // Uploaded file URLs keep their original name, spaces included.
  final uri = Uri.tryParse(value.contains(' ') ? Uri.encodeFull(value) : value);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException {
    return false;
  }
}
