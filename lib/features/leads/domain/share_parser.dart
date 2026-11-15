/// Turns text shared from Google Maps (or anywhere) into lead fields.
///
/// Typical Maps shares:
///   "Chai Point\nRoad No. 36, Jubilee Hills, Hyderabad, Telangana 500033\nhttps://maps.app.goo.gl/AbC123"
///   "Chai Point, Road No. 36, Jubilee Hills https://maps.app.goo.gl/AbC123"
///   "https://maps.app.goo.gl/AbC123"
class SharedPlace {
  const SharedPlace({this.name = '', this.address = '', this.url = '', this.phone = '', this.email = ''});
  final String name;
  final String address;
  final String url;
  final String phone;
  final String email;

  bool get isMaps =>
      url.contains('maps.app.goo.gl') ||
      url.contains('google.com/maps') ||
      url.contains('goo.gl/maps') ||
      url.contains('maps.google.');
}

final _url = RegExp(r'https?://\S+');
final _phone = RegExp(r'(\+?91[\s-]?)?[6-9]\d{4}[\s-]?\d{5}\b|\b0\d{2,4}[\s-]?\d{6,8}\b');
final _mail = RegExp(r'[^\s@]+@[^\s@]+\.[a-zA-Z]{2,}');

SharedPlace parseSharedText(String raw) {
  var text = raw.replaceAll('\r', '').trim();
  final urls = _url.allMatches(text).map((m) => m.group(0)!).toList();
  final url = urls.firstWhere(
    (u) => u.contains('maps') || u.contains('goo.gl'),
    orElse: () => urls.isEmpty ? '' : urls.first,
  );
  for (final u in urls) {
    text = text.replaceAll(u, ' ');
  }
  final phone = _phone.firstMatch(text)?.group(0)?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
  final email = _mail.firstMatch(text)?.group(0) ?? '';
  if (phone.isNotEmpty) text = text.replaceFirst(_phone, ' ');
  if (email.isNotEmpty) text = text.replaceFirst(email, ' ');
  final lines = text
      .split('\n')
      .map((l) => l.trim().replaceAll(RegExp(r'\s{2,}'), ' '))
      .where((l) => l.isNotEmpty)
      .toList();
  String name = '', address = '';
  if (lines.length >= 2) {
    name = lines.first;
    address = lines.skip(1).join(', ');
  } else if (lines.length == 1) {
    final l = lines.first;
    final comma = l.indexOf(',');
    // "Name, street, area…": the first part is the name if the rest looks like an address.
    if (comma > 0 && l.substring(comma + 1).trim().length > 6) {
      name = l.substring(0, comma).trim();
      address = l.substring(comma + 1).trim();
    } else {
      name = l;
    }
  }
  name = name.replaceAll(RegExp(r'[,·•|-]+$'), '').trim();
  address = address.replaceAll(RegExp(r'^[,·•|\s-]+|[,·•|\s-]+$'), '').replaceAll(RegExp(r',\s*,'), ',');
  return SharedPlace(name: name, address: address, url: url, phone: phone, email: email);
}
