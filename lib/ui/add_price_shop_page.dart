import 'package:flutter/material.dart';
import 'package:openprices/model/dao_osm.dart';
import 'package:openprices/model/local_database.dart';
import 'package:openprices/model/osm_node.dart';
import 'package:openprices/ui/add_price_date_page.dart';
import 'package:openprices/ui/map_page.dart';
import 'package:provider/provider.dart';

class AddPriceShopPage extends StatefulWidget {
  const AddPriceShopPage({super.key});

  @override
  State<AddPriceShopPage> createState() => _AddPriceShopPageState();
}

class _AddPriceShopPageState extends State<AddPriceShopPage> {
  @override
  Widget build(BuildContext context) {
    final DaoOSM daoOSM = DaoOSM(context.read<LocalDatabase>());
    final List<String> keys = List.from(daoOSM.getAllKeys());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add prices'),
      ),
      body: ListView.builder(
        itemCount: keys.length + 2,
        itemBuilder: (final BuildContext context, int index) {
          if (index == 0) {
            return const ListTile(title: Text('Step 1: select the shop'));
          }
          index--;
          if (index == 0) {
            return Card(
              child: ListTile(
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const MapPage(),
                    ),
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() {});
                },
                leading: const Icon(Icons.map),
                title: const Text('Find new shops in the map'),
              ),
            );
          }
          index--;
          final String key = keys[index];
          final String json = daoOSM.get(key)!;
          final OsmNode place = OsmNode.fromJson(key: key, json: json);
          return GestureDetector(
            onTap: () async => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => AddPriceDatePage(
                  place: place,
                ),
              ),
            ),
            child: Card(
              child: Text(place.getTagsAsLines().join('\n')),
            ),
          );
        },
      ),
    );
  }
}
