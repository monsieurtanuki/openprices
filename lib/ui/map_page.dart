import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_overpass/flutter_overpass.dart';
import '../model/dao_double.dart';
import '../model/dao_osm.dart';
import '../local/local_database.dart';
import '../model/osm_node.dart';
import '../local/tile_provider.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const String _tagDoubleZoom = 'zoom';
  static const String _tagDoubleLatitude = 'latitude';
  static const String _tagDoubleLongitude = 'longitude';

  @override
  void initState() {
    super.initState();
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoDouble daoDouble = DaoDouble(localDatabase);
    _initialCenter = LatLng(
      daoDouble.get(_tagDoubleLatitude) ?? 48.8439808,
      daoDouble.get(_tagDoubleLongitude) ?? 2.3986176,
    );
    _initialZoom = daoDouble.get(_tagDoubleZoom) ?? 13;
    _initialRotation = 0;

    _mapController.mapEventStream.listen((event) {
      daoDouble.put(_tagDoubleLatitude, event.camera.center.latitude);
      daoDouble.put(_tagDoubleLongitude, event.camera.center.longitude);
      daoDouble.put(_tagDoubleZoom, event.camera.zoom);
    });

    _refreshAllMarkers();
  }

  final List<Marker> _allMarkers = <Marker>[];
  List<dynamic>? _elements;

  final MapController _mapController = MapController();
  late final LatLng _initialCenter;
  late final double _initialZoom;
  late final double _initialRotation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          if (_allMarkers.isNotEmpty)
            IconButton(
              tooltip: 'Expand bounds to all know shops',
              icon: const Icon(Icons.zoom_out_map),
              onPressed: () async {
                final List<LatLng> bounds = _getBounds();
                if (bounds.length == 1) {
                  _mapController.move(bounds.first, _mapController.camera.zoom);
                } else {
                  _mapController.fitCamera(
                    CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(bounds),
                      padding: const EdgeInsets.all(24),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _initialCenter,
          initialZoom: _initialZoom,
          initialRotation: _initialRotation,
          interactionOptions: const InteractionOptions(
            // TODO: 2 get rid of rotation effect
            rotationThreshold: double.maxFinite,
            rotationWinGestures: MultiFingerGesture.none,
            pinchZoomWinGestures: MultiFingerGesture.pinchMove,
          ),
          maxZoom: 18,
        ),
        children: [
          openStreetMapTileLayer,
          MarkerLayer(
            markers: _allMarkers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final double zoom = _mapController.camera.zoom;
          const int minZoom = 16;
          if (zoom < minZoom) {
            await showDialog(
              context: context,
              builder: (final BuildContext context) => AlertDialog(
                title: const Text('Zoom in!'),
                content: Text(
                  'Minimum zoom for local shop search is $minZoom.'
                  '\n'
                  'Current zoom level is ${zoom.toStringAsFixed(2)}.'
                  '\n'
                  'Please zoom in!',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  )
                ],
              ),
            );
            return;
          }
          final ScaffoldMessengerState state = ScaffoldMessenger.of(context);
          state.showSnackBar(
            const SnackBar(content: Text('Looking for local shops...')),
          );
          try {
            final dynamic results = await _findShopQuery();
            _elements = results['elements'];
            _refreshAllMarkers();
            setState(() {});
            state.showSnackBar(
              SnackBar(
                content: Text('${_allMarkers.length} shops (as NODE) found'),
              ),
            );
          } catch (e) {
            state.showSnackBar(
              SnackBar(content: Text('Exception: $e')),
            );
          }
        },
        tooltip: 'Looking for a local shop',
        child: const Icon(Icons.location_searching),
      ),
    );
  }

  Future<dynamic> _findShopQuery() async {
    final LatLngBounds bounds = _mapController.camera.visibleBounds;
    final FlutterOverpass flutterOverpass = FlutterOverpass();

    double getSouth() => bounds.south;

    double getWest() => bounds.west;

    double getNorth() => bounds.north;

    double getEast() => bounds.east;

    return flutterOverpass.rawOverpassQL(
      query:
          'nwr[shop](${getSouth()},${getWest()},${getNorth()},${getEast()});',
      outputQuery: '[out:json];',
      useOutBody: true,
    );
  }

  List<LatLng> _getBounds() {
    final List<LatLng> bounds = <LatLng>[];
    for (final Marker marker in _allMarkers) {
      bounds.add(marker.point);
    }
    return bounds;
  }

  void _refreshAllMarkers() {
    _allMarkers.clear();
    _refreshNewMarkers();
    // existing (more important?) markers on top
    _refreshExistingMarkers();
  }

  void _refreshNewMarkers() {
    if (_elements == null) {
      return;
    }
    for (final Map<String, dynamic> element in _elements!) {
      if (element['type'] != 'node') {
        continue;
      }
      final OsmNode place = OsmNode.fromMap(element);
      final DaoOSM daoOSM = DaoOSM(context.read<LocalDatabase>());
      final String? existingJson = daoOSM.get(place.key);
      if (existingJson == null) {
        _allMarkers.add(_getNewPlace(place));
      }
    }
  }

  static const double _sizeExisting = 36;
  static const double _sizeNew = 24;
  static const Color _colorExisting = Colors.red;
  static const Color _colorNew = Colors.blue;
  static const IconData _iconExisting = Icons.shopping_cart;
  static const IconData _iconNew = Icons.shopping_cart_checkout;

  void _refreshExistingMarkers() {
    final DaoOSM daoOSM = DaoOSM(context.read<LocalDatabase>());
    final Iterable<dynamic> keys = daoOSM.getAllKeys();
    for (final String key in keys) {
      final String json = daoOSM.get(key)!;
      final OsmNode place = OsmNode.fromJson(key: key, json: json);
      _allMarkers.add(_getExistingPlace(place));
    }
  }

  Marker _getNewPlace(final OsmNode place) => Marker(
        point: place.latLng,
        child: IconButton(
          icon: const Icon(
            _iconNew,
            color: _colorNew,
            size: _sizeNew,
          ),
          onPressed: () async {
            final bool? result = await showDialog<bool>(
              context: context,
              builder: (final BuildContext context) {
                final List<String> lines = place.getTagsAsLines();
                return AlertDialog(
                  title: Text('Add shop ${place.key}?'),
                  content: Text(lines.join('\n')),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.add),
                      label: const Text('Add local shop'),
                    ),
                  ],
                );
              },
            );
            if (!mounted) {
              return;
            }
            if (result == true) {
              await DaoOSM(context.read<LocalDatabase>()).put(
                place.key,
                jsonEncode(place.getJson()),
              );
              _refreshAllMarkers();
              setState(() {});
            }
          },
        ),
      );

  Marker _getExistingPlace(final OsmNode place) => Marker(
        point: place.latLng,
        child: IconButton(
          icon: const Icon(
            _iconExisting,
            color: _colorExisting,
            size: _sizeExisting,
          ),
          onPressed: () async {
            final _Action? result = await showDialog<_Action>(
              context: context,
              builder: (final BuildContext context) {
                final List<String> keys = List.of(place.tags.keys);
                keys.sort();
                final List<String> items = <String>[];
                for (final String key in keys) {
                  items.add('$key => ${place.tags[key]}');
                }
                final ColorScheme colorScheme = Theme.of(context).colorScheme;
                return AlertDialog(
                  title: Text('Shop ${place.key}'),
                  content: Text(items.join('\n')),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_Action.none),
                      child: const Text('Cancel'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pop(_Action.delete),
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove local shop'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          colorScheme.error,
                        ),
                        foregroundColor: MaterialStatePropertyAll(
                          colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            if (!mounted) {
              return;
            }
            switch (result) {
              case null:
              case _Action.none:
                return;
              case _Action.delete:
                await DaoOSM(context.read<LocalDatabase>()).put(
                  place.key,
                  null,
                );
                _refreshAllMarkers();
                setState(() {});
                return;
            }
          },
        ),
      );
}

enum _Action {
  none,
  delete,
}
