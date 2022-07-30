import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository.dart';

final neteaseRepositoryProvider = Provider<NetworkRepository>(
  (ref) => throw UnimplementedError('init with override'),
);
