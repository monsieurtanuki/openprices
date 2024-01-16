import 'package:flutter/material.dart';
import 'package:openprices/ui/add_price_shop_page.dart';
import 'package:openprices/ui/map_page.dart';
import 'package:openprices/ui/show_price_page.dart';
import 'package:openprices/ui/user_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Open Prices Demo Home Page'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                onTap: () async => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const MapPage(),
                  ),
                ),
                leading: const Icon(Icons.map),
                title: const Text('Map'),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const UserPage(),
                  ),
                ),
                leading: const Icon(Icons.login),
                title: const Text('User'),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const AddPriceShopPage(),
                  ),
                ),
                leading: const Icon(Icons.add),
                title: const Text('Add prices'),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const ShowPricePage(),
                  ),
                ),
                leading: const Icon(Icons.list),
                title: const Text('Show prices'),
              ),
            ),
          ],
        ),
      );
}
