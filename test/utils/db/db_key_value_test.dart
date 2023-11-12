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
}
