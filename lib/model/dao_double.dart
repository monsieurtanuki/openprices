import 'package:hive_flutter/hive_flutter.dart';
import '../local/abstract_dao.dart';

/// Where we store double's.
class DaoDouble extends AbstractDao {
  const DaoDouble(super.localDatabase);

  static const String _hiveBoxName = 'double';

  @override
  Future<void> init() async => Hive.openBox<double>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<double> _getBox() => Hive.box<double>(_hiveBoxName);

  double? get(final String key) => _getBox().get(key);

  Future<void> put(final String key, final double? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);
}
