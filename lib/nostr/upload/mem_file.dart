import 'dart:typed_data';

class MemFile {
  Uint8List bytes;
  final String mimeType;
  final String name;

  MemFile({
    required this.bytes,
    required this.mimeType,
    required this.name,
  });
}
