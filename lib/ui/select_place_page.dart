import 'package:flutter/material.dart';
import 'package:openprices/local/dao_string.dart';
import 'package:openprices/ui/add_price_page.dart';
import 'package:openprices/ui/place_page.dart';
import '../model/dao_osm.dart';
import '../local/local_database.dart';
import '../model/osm_node.dart';
import '../ui/map_page.dart';
import 'package:provider/provider.dart';

class SelectPlacePage extends StatefulWidget {
  const SelectPlacePage({super.key});

  @override
  State<SelectPlacePage> createState() => _SelectPlacePageState();
}

class _SelectPlacePageState extends State<SelectPlacePage> {
  static const IconData _iconData = Icons.map;

  @override
  Widget build(BuildContext context) {
    final DaoOSM daoOSM = DaoOSM(context.read<LocalDatabase>());
    final List<String> keys = List.from(daoOSM.getAllKeys());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a place'),
      ),
      floatingActionButton: keys.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async => _openMapPage(),
              child: const Icon(_iconData),
            ),
      body: keys.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                onPressed: () async => _openMapPage(),
                icon: const Icon(_iconData),
                label: const Text('Find places in the map!'),
              ),
            )
          : ListView.builder(
              itemCount: keys.length,
              itemBuilder: (final BuildContext context, int index) {
                final String key = keys[index];
                final String json = daoOSM.get(key)!;
                final OsmNode place = OsmNode.fromJson(key: key, json: json);
                final String nickname = place.nickname;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.check),
                    onTap: () async {
                      final LocalDatabase localDatabase =
                          context.read<LocalDatabase>();
                      final DaoString daoString = DaoString(localDatabase);
                      await daoString.put(
                        AddPricePage.daoStringTagPlace,
                        key,
                      );
                      if (!mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async => _openPlacePage(key),
                    ),
                    title: Text(
                      nickname.isNotEmpty
                          ? nickname
                          : place.getTagsAsLines().join('\n'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _openMapPage() async {
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
  }

  Future<void> _openPlacePage(final String osmKey) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PlacePage(osmKey: osmKey),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
