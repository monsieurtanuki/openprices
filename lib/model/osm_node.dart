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
        tags[fakeTagLatitude],
        tags[fakeTagLongitude],
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

  String get nickname => tags[fakeTagNickname] ?? '';

  set nickname(String value) => tags[fakeTagNickname] = value;

  Map<String, dynamic> getJson() => tags;

  static const String fakeTagLatitude = '__lat';
  static const String fakeTagLongitude = '__lon';
  static const String fakeTagNickname = '__nickname';

  static Map<String, dynamic> _getTags(
    final double latitude,
    final double longitude,
    final Map<String, dynamic> tags,
  ) {
    tags[fakeTagLatitude] = latitude;
    tags[fakeTagLongitude] = longitude;
    return tags;
  }
}
