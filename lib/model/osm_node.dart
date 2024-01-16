import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class OsmNode {
  const OsmNode._({
    required this.id,
    required this.tags,
  });

  OsmNode.fromMap(dynamic map)
      : this._(
          id: map['id'],
          tags: _getTags(map['lat'], map['lon'], map['tags']),
        );

  OsmNode.fromJson({
    required final String key,
    required String json,
  }) : this._(
          id: int.parse(key.substring(1)),
          tags: jsonDecode(json),
        );

  final int id;
  final Map<String, dynamic> tags;

  String get key => 'N$id';

  LocationOSMType get type => LocationOSMType.node;

  LatLng get latLng => LatLng(
        tags[_fakeTagLatitude],
        tags[_fakeTagLongitude],
      );

  List<String> getTagsAsLines() {
    final List<String> keys = List.from(tags.keys);
    keys.sort();
    final List<String> items = <String>[];
    for (final String key in keys) {
      items.add('$key: ${tags[key]}');
    }
    return items;
  }

  Map<String, dynamic> getJson() => tags;

  static const String _fakeTagLatitude = '__lat';
  static const String _fakeTagLongitude = '__lon';

  static Map<String, dynamic> _getTags(
    final double latitude,
    final double longitude,
    final Map<String, dynamic> tags,
  ) {
    tags[_fakeTagLatitude] = latitude;
    tags[_fakeTagLongitude] = longitude;
    return tags;
  }
}
