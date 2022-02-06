import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps/constatns.dart';
import 'package:maps/location_service.dart';

void main() async {
  var loc = await LocationService.getLocation();
  runApp(MyApp(loc));
}

class MyApp extends StatelessWidget {
  LatLng loc;
  MyApp(this.loc);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapScreen(loc),
    );
  }
}

class LoadScreen extends StatelessWidget {
  const LoadScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: DecorationImage(image: Image.file()),
    );
  }
}

class MapScreen extends StatefulWidget {
  LatLng loc;
  MapScreen(this.loc);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location currentLocation = Location();
  LatLng? _currentLatLng;
  LatLng? _selectedLatLng;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  late int _markerIdCounter;
  int _defIdValue = 0;
  Completer<GoogleMapController> _mapController = Completer();

  

  @override
  void initState() {
    super.initState();
    Map<MarkerId, Marker> _markers = <MarkerId, Marker>{}; //ну типа гет с сервера тут, или сделать его выше
    _markerIdCounter = _defIdValue + 1;
    setState(() {
      _currentLatLng = widget.loc;
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    if (_currentLatLng == null) {
      _currentLatLng = moscowCoords;
    }
    MarkerId markerId = MarkerId(_markerIdVal());
    LatLng position = _currentLatLng!;
    Marker marker = Marker(
      markerId: markerId,
      position: position,
      draggable: false,
    );
    setState(() {
      _markers[markerId] = marker;
    });
    moveCamera(position);
  }

  Future<void> moveCamera(LatLng position) async {
    Future.delayed(Duration(seconds: 1), () async {
      GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 17.0,
          ),
        ),
      );
    });
  }

  String _markerIdVal({bool def = true}) {
    String val;
    if (def) {
      val = 'marker_id_$_defIdValue';
    } else {
      val = 'marker_id_$_markerIdCounter';
      _markerIdCounter++;
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                MarkerId markerId = MarkerId(_markerIdVal(def: false));
                Marker marker = Marker(
                  markerId: markerId,
                  position: _selectedLatLng!,
                  onTap: () {}, //TODO хз, алерт какой
                );
                setState(() {
                  _markers[markerId] = marker;
                  print(_markers.length);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  print(_markers.length);
                  moveCamera(_currentLatLng!);
                });
              },
            ),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GoogleMap(
          markers: Set<Marker>.of(_markers.values),
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentLatLng ?? moscowCoords,
            zoom: 17.0,
          ),
          myLocationEnabled: true,
          onCameraMove: (CameraPosition position) {
            _selectedLatLng = position.target;
            if (_markers.length > 0) {
              MarkerId markerId = MarkerId(_markerIdVal());
              Marker marker = _markers[markerId]!;
              Marker updatedMarker = marker.copyWith(
                positionParam: position.target,
              );
              setState(() {
                _markers[markerId] = updatedMarker;
              });
            }
          },
        ),
      ),
    );
  }
}
