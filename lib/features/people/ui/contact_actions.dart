import 'package:url_launcher/url_launcher.dart';

/// Indian numbers without a country code get +91.
String waNumber(String phone) {
  var d = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.length == 10) d = '91$d';
  if (d.startsWith('0') && d.length == 11) d = '91${d.substring(1)}';
  return d;
}

Future<bool> callNumber(String phone) => launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

Future<bool> whatsapp(String phone, {String text = ''}) => launchUrl(
  Uri.parse('https://wa.me/${waNumber(phone)}${text.isEmpty ? '' : '?text=${Uri.encodeComponent(text)}'}'),
  mode: LaunchMode.externalApplication,
);

Future<bool> emailTo(String email, {String subject = '', String body = ''}) => launchUrl(
  Uri(
    scheme: 'mailto',
    path: email,
    query: [
      if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&'),
  ),
);

Future<bool> openUrl(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
