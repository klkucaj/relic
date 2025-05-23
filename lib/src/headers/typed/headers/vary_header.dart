import '../../../../relic.dart';
import '../../extension/string_list_extensions.dart';

/// A class representing the HTTP Vary header.
///
/// This class manages the list of headers that the response may vary on,
/// and can also handle the wildcard value "*", which indicates that the
/// response varies on all request headers.
final class VaryHeader {
  static const codec = HeaderCodec(VaryHeader.parse, ___encode);
  static List<String> ___encode(final VaryHeader value) => [value._encode()];

  /// A list of headers that the response varies on.
  /// If the list contains only "*", it means all headers are varied on.
  final Iterable<String>? fields;

  /// Whether all headers are allowed to vary (`*`).
  final bool isWildcard;

  /// Constructs an instance allowing specific headers to vary.
  VaryHeader.headers({required this.fields}) : isWildcard = false;

  /// Constructs an instance allowing all headers to vary (`*`).
  VaryHeader.wildcard()
      : fields = null,
        isWildcard = true;

  /// Parses the Vary header value and returns a [VaryHeader] instance.
  ///
  /// This method handles the wildcard value "*" or splits the value by commas and trims each field.
  factory VaryHeader.parse(final Iterable<String> values) {
    final splitValues = values.splitTrimAndFilterUnique();

    if (splitValues.isEmpty) {
      throw const FormatException('Value cannot be empty');
    }

    if (splitValues.length == 1 && splitValues.first == '*') {
      return VaryHeader.wildcard();
    }

    if (splitValues.length > 1 && splitValues.contains('*')) {
      throw const FormatException(
          'Wildcard (*) cannot be used with other values');
    }

    return VaryHeader.headers(fields: splitValues);
  }

  /// Converts the [VaryHeader] instance into a string representation
  /// suitable for HTTP headers.
  String _encode() => isWildcard ? '*' : fields!.join(', ');

  @override
  String toString() {
    return 'VaryHeader(fields: $fields, isWildcard: $isWildcard)';
  }
}
