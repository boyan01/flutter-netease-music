import 'package:hive/hive.dart';

extension HiveExt on HiveInterface {
  Future<Box<T>> openBoxSafe<T>(String name) async {
    try {
      return await openBox<T>(
        name,
        compactionStrategy: (entries, deleted) => false,
      );
    } catch (error) {
      await Hive.deleteBoxFromDisk(name);
      return openBox<T>(name);
    }
  }
}
