import 'package:flutter_test/flutter_test.dart';
import 'package:quiet/utils/db/db_key_value.dart';

void main() {
  test('convert to type', () {
    expect(convertToType<int>('123'), 123);
    expect(convertToType<Map<String, dynamic>>('{}'), {});
    expect(convertToType<Map>('{}'), {});
    expect(convertToType<Map<String, dynamic>>('{"a":1}'), {'a': 1});
    expect(convertToType<List<Map<String, dynamic>>>('[{"a":1}]'), [
      {'a': 1},
    ]);
    expect(convertToType<List<dynamic>>('[{"a":1}]'), [
      {'a': 1},
    ]);
  });

  test('convert to string', () {
    expect(convertToString(123), '123');
    expect(convertToString({}), '{}');
    expect(convertToString({}), '{}');
    expect(convertToString({'a': 1}), '{"a":1}');
    expect(
      convertToString([
        {'a': 1},
      ]),
      '[{"a":1}]',
    );
    expect(
      convertToString([
        {'a': 1},
      ]),
      '[{"a":1}]',
    );
    expect(convertToString('abc'), 'abc');
  });

  test('test key value', () async {
    expect(
      convertToType<bool>(convertToString(true)),
      true,
    );
    expect(
      convertToType<bool>(convertToString(false)),
      false,
    );
    expect(
      convertToType<bool>(convertToString(null)),
      null,
    );
    expect(
      convertToType<String>(convertToString('true')),
      'true',
    );
    expect(convertToType<int>(convertToString(1)), 1);
    expect(
      convertToType<double>(convertToString(1.0)),
      1.0,
    );
    expect(
      convertToType<Map<String, dynamic>>(
        convertToString({'a': 1}),
      ),
      {'a': 1},
    );
    expect(
      convertToType<List<Map<String, dynamic>>>(
        convertToString(
          [
            {'a': 1},
          ],
        ),
      ),
      [
        {'a': 1},
      ],
    );
  });
}
