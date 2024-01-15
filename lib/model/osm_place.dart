import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:latlong2/latlong.dart';

class OsmPlace {
  const OsmPlace({
    required this.type,
    required this.id,
    required this.latLng,
    required this.tags,
  });

  OsmPlace.fromMap(dynamic map)
      : this(
          type: OsmPlace.fromLowerCase(map['type']),
          id: map['id'],
          latLng: LatLng(map['lat'], map['lon']),
          tags: map['tags'],
        );

  static LocationOSMType fromLowerCase(final String value) {
    for (final LocationOSMType type in LocationOSMType.values) {
      if (type.name == value) {
        return type;
      }
    }
    throw Exception(
      'Unknown OSM type: $value not in ${LocationOSMType.values}',
    );
  }

  final LocationOSMType type;
  final int id;
  final LatLng latLng;
  final Map<String, dynamic> tags;
}
