import 'package:hive_flutter/hive_flutter.dart';
import '../local/abstract_dao.dart';

/// Where we store OSM data.
class DaoOSM extends AbstractDao {
  const DaoOSM(super.localDatabase);

  static const String _hiveBoxName = 'osm';

  @override
  Future<void> init() async => Hive.openBox<String>(_hiveBoxName);

  @override
  void registerAdapter() {}

  Box<String> _getBox() => Hive.box<String>(_hiveBoxName);

  String? get(final String key) => _getBox().get(key);

  Future<void> put(final String key, final String? value) async =>
      value == null ? _getBox().delete(key) : _getBox().put(key, value);

  Iterable<dynamic> getAllKeys() => _getBox().keys;
}
