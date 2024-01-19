import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openprices/ui/common.dart';
import '../model/dao_osm.dart';
import '../local/local_database.dart';
import '../model/osm_node.dart';
import 'package:provider/provider.dart';

class PlacePage extends StatefulWidget {
  const PlacePage({
    required this.osmKey,
    super.key,
  });

  final String osmKey;

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  final TextEditingController _controller = TextEditingController();

  late OsmNode _place;

  @override
  void initState() {
    super.initState();
    final DaoOSM daoOSM = DaoOSM(context.read<LocalDatabase>());
    final String key = widget.osmKey;
    final String json = daoOSM.get(key)!;
    _place = OsmNode.fromJson(key: key, json: json);
    _controller.text = _place.nickname;
  }

  // TODO: 1 add map
  // TODO: 1 remove "__" from display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _controller,
              onChanged: (final String changed) => setState(
                () => _place.nickname = changed,
              ),
              decoration: getDecoration(
                hintText: 'Nickname',
                prefixIcon: const Icon(Icons.place),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async =>
                      DaoOSM(context.read<LocalDatabase>()).put(
                    _place.key,
                    jsonEncode(_place.getJson()),
                  ),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(
                _place.getTagsAsLines().join('\n'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
