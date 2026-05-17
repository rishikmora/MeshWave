import 'dart:convert';
import 'dart:typed_data';

class PayloadOptimizer {
  static const Map<String, String> _dictionary = {
    'emergency': '~e',
    'battery': '~b',
    'location': '~l',
    'acknowledge': '~a',
    'medical': '~m',
    'evacuation': '~v',
    'coordinates': '~c',
    'water': '~w',
    'shelter': '~s',
    'signal': '~g',
  };

  Uint8List compressText(String message) {
    var output = message.trim();
    for (final entry in _dictionary.entries) {
      output = output.replaceAll(
        RegExp(entry.key, caseSensitive: false),
        entry.value,
      );
    }
    return Uint8List.fromList(utf8.encode(output));
  }

  String decompressText(Uint8List payload) {
    var output = utf8.decode(payload);
    for (final entry in _dictionary.entries) {
      output = output.replaceAll(entry.value, entry.key);
    }
    return output;
  }

  int estimateAirtimeScore(Uint8List payload) {
    final lengthScore = payload.length;
    final entropy = payload.toSet().length;
    return lengthScore + entropy;
  }
}
