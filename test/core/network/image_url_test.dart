import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/network/image_url.dart';

void main() {
  const base = 'https://api.example.com/api/';
  test('absolute stays, relative resolves against API host, empty is null', () {
    expect(resolveImageUrl('https://cdn.x.com/a.jpg', base: base), 'https://cdn.x.com/a.jpg');
    expect(resolveImageUrl('/storage/p/1.jpg', base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(resolveImageUrl('storage/p/1.jpg', base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(resolveImageUrl('', base: base), isNull);
    expect(resolveImageUrl(null, base: base), isNull);
  });
}
