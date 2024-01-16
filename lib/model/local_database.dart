import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openprices/model/dao_osm.dart';
import 'package:openprices/model/dao_string.dart';
import 'abstract_dao.dart';
import 'dao_double.dart';

class LocalDatabase extends ChangeNotifier {
  LocalDatabase._();

  static Future<LocalDatabase> getLocalDatabase() async {
    final LocalDatabase localDatabase = LocalDatabase._();

    // only hive from there
    await Hive.initFlutter();
    final List<AbstractDao> daos = <AbstractDao>[
      DaoDouble(localDatabase),
      DaoString(localDatabase),
      DaoOSM(localDatabase),
    ];
    for (final AbstractDao dao in daos) {
      dao.registerAdapter();
    }
    for (final AbstractDao dao in daos) {
      await dao.init();
    }

    return localDatabase;
  }

  static int nowInMillis() => DateTime.now().millisecondsSinceEpoch;
}
