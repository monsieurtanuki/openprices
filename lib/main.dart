import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'local/local_database.dart';
import 'local/home_page.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() async {
  await _init();
  runApp(const MyApp());
}

late LocalDatabase _localDatabase;

Future<void> _init() async {
  _localDatabase = await LocalDatabase.getLocalDatabase();
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: "monsieurtanuki's open prices",
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // The `create` constructor of [ChangeNotifierProvider] takes care of
    // disposing the value.
    ChangeNotifierProvider<T> provide<T extends ChangeNotifier>(T value) =>
        ChangeNotifierProvider<T>(create: (BuildContext context) => value);

    return MultiProvider(
      providers: <SingleChildWidget>[
        provide<LocalDatabase>(_localDatabase),
      ],
      child: MaterialApp(
        title: 'Open Price Demo',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
