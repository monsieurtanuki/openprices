import 'package:hive_flutter/hive_flutter.dart';
import 'abstract_dao.dart';

/// Where we store String's.
class DaoString extends AbstractDao {
  const DaoString(super.localDatabase);

  static const String _hiveBoxName = 'string';

  @override
  Future<void> init() async => Hive.openBox<String>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<String> _getBox() => Hive.box<String>(_hiveBoxName);

  String? get(final String key) => _getBox().get(key);

  Future<void> put(final String key, final String? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);
}
