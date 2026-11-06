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

  test('local dev URLs rewrite scheme and host to target origin', () {
    expect(resolveImageUrl('http://localhost:8000/storage/p/1.jpg', base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(resolveImageUrl('http://127.0.0.1:8000/storage/p/1.jpg', base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(resolveImageUrl('http://api.example.com/storage/p/1.jpg', base: base), 'https://api.example.com/storage/p/1.jpg');
  });

  test('extractImageUrl parses String, Map, and List JSON payloads', () {
    expect(extractImageUrl('storage/p/1.jpg', base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(extractImageUrl({'image_url': 'storage/p/1.jpg'}, base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(extractImageUrl({'url': '/storage/p/1.jpg'}, base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(extractImageUrl([{'url': 'storage/p/1.jpg'}], base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(extractImageUrl(['storage/p/1.jpg'], base: base), 'https://api.example.com/storage/p/1.jpg');
    expect(extractImageUrl(null, base: base), isNull);
  });
}
