import 'package:test/test.dart';
import 'package:relic/src/headers/headers.dart';
import 'package:relic/src/relic_server.dart';

import '../headers_test_utils.dart';
import '../docs/strict_validation_docs.dart';

/// Reference: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Transfer-Encoding
/// About empty value test, check the [StrictValidationDocs] class for more details.
void main() {
  group('Given a Transfer-Encoding header with the strict flag true', () {
    late RelicServer server;

    setUp(() async {
      server = await createServer(strictHeaders: true);
    });

    tearDown(() => server.close());

    test(
      'when an empty Transfer-Encoding header is passed then the server should respond with a bad request '
      'including a message that states the encodings cannot be empty',
      () async {
        expect(
          () async => await getServerRequestHeaders(
            server: server,
            headers: {'transfer-encoding': ''},
          ),
          throwsA(isA<BadRequestException>().having(
            (e) => e.message,
            'message',
            contains('Value cannot be empty'),
          )),
        );
      },
    );

    test(
      'when an invalid Transfer-Encoding header is passed then the server should respond with a bad request '
      'including a message that states the value is invalid',
      () async {
        expect(
          () async => await getServerRequestHeaders(
            server: server,
            headers: {'transfer-encoding': 'custom-encoding'},
          ),
          throwsA(isA<BadRequestException>().having(
            (e) => e.message,
            'message',
            contains('Invalid value'),
          )),
        );
      },
    );

    test(
      'when a valid Transfer-Encoding header is passed then it should parse the encodings correctly',
      () async {
        Headers headers = await getServerRequestHeaders(
          server: server,
          headers: {'transfer-encoding': 'chunked, gzip'},
        );

        expect(
          headers.transferEncoding?.encodings.map((e) => e.name),
          equals(['chunked', 'gzip']),
        );
      },
    );

    test(
      'when a Transfer-Encoding header with duplicate encodings is passed then '
      'it should parse the encodings correctly and remove duplicates',
      () async {
        Headers headers = await getServerRequestHeaders(
          server: server,
          headers: {'transfer-encoding': 'chunked, gzip, chunked'},
        );

        expect(
          headers.transferEncoding?.encodings.map((e) => e.name),
          equals(['chunked', 'gzip']),
        );
      },
    );

    test(
      'when a Transfer-Encoding header contains "chunked" then isChunked should be true',
      () async {
        Headers headers = await getServerRequestHeaders(
          server: server,
          headers: {'transfer-encoding': 'chunked, gzip'},
        );

        expect(headers.transferEncoding?.isChunked, isTrue);
      },
    );

    test(
      'when no Transfer-Encoding header is passed then it should return null',
      () async {
        Headers headers = await getServerRequestHeaders(
          server: server,
          headers: {},
        );

        expect(headers.transferEncoding, isNull);
      },
    );
  });

  group('Given a Transfer-Encoding header with the strict flag false', () {
    late RelicServer server;

    setUp(() async {
      server = await createServer(strictHeaders: false);
    });

    tearDown(() => server.close());

    group('when an empty Transfer-Encoding header is passed', () {
      test(
        'then it should return null',
        () async {
          Headers headers = await getServerRequestHeaders(
            server: server,
            headers: {'transfer-encoding': ''},
          );

          expect(headers.transferEncoding, isNull);
        },
      );
      test(
        'then it should be recorded in the "failedHeadersToParse" field',
        () async {
          Headers headers = await getServerRequestHeaders(
            server: server,
            headers: {'transfer-encoding': ''},
          );

          expect(
            headers.failedHeadersToParse['transfer-encoding'],
            equals(['']),
          );
        },
      );
    });
  });
}
