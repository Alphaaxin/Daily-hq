import 'package:flutter_test/flutter_test.dart';
import 'package:nizam/features/leads/domain/share_parser.dart';

void main() {
  test('Maps share: name, address lines and link', () {
    final p = parseSharedText(
      'Chai Point\nRoad No. 36, Jubilee Hills\nHyderabad, Telangana 500033\nhttps://maps.app.goo.gl/AbC123xyz',
    );
    expect(p.name, 'Chai Point');
    expect(p.address, 'Road No. 36, Jubilee Hills, Hyderabad, Telangana 500033');
    expect(p.url, 'https://maps.app.goo.gl/AbC123xyz');
    expect(p.isMaps, isTrue);
  });

  test('single line with commas', () {
    final p = parseSharedText('Pista House, Shah Ali Banda Rd, Charminar https://maps.app.goo.gl/Q9');
    expect(p.name, 'Pista House');
    expect(p.address, 'Shah Ali Banda Rd, Charminar');
  });

  test('link only', () {
    final p = parseSharedText('https://maps.app.goo.gl/OnlyLink');
    expect(p.name, '');
    expect(p.url, 'https://maps.app.goo.gl/OnlyLink');
  });

  test('picks out phone and e-mail', () {
    final p = parseSharedText(
      'Glow Salon\nBanjara Hills\n+91 98480 12345\nhello@glowsalon.in\nhttps://maps.google.com/?cid=1',
    );
    expect(p.phone, '+919848012345');
    expect(p.email, 'hello@glowsalon.in');
    expect(p.address, 'Banjara Hills');
    expect(p.isMaps, isTrue);
  });

  test('plain text from elsewhere', () {
    final p = parseSharedText('Rahul from the expo, wants a website');
    expect(p.name, 'Rahul from the expo');
    expect(p.isMaps, isFalse);
  });
}
