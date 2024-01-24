import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';


// Class that stores site details
class SiteLatLng {
  double lat;
  double lng;
  String name;
  bool online;

  SiteLatLng({required this.lat, required this.lng, required this.name, required this.online});
}





class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}


class LoginPageState extends State<LoginPage> {
  // _mapController contains the setting for the generated map
  late final MapController _mapController;

  // textControllerSite: text controller for search bar
  final textControllerSite = TextEditingController();


  // centreLat,centreLng, intZoomLevel are the default map values
  // Map always initialized using these values
  double centreLat = 0;
  double centreLng = 0;
  double intZoomLevel = 3;

  // Location stream variables for live truck view
  // late final StreamController<LocationMarkerPosition> _positionStreamController;
  // late final StreamController<LocationMarkerHeading> _headingStreamController;
  StreamController<LocationMarkerPosition> _positionStreamController = StreamController();
  StreamController<LocationMarkerHeading> _headingStreamController = StreamController();


  double _currentLat = 0;
  double _currentLng = 0;
  bool _liveTruck = false;
  SiteLatLng _liveTruckName = SiteLatLng(lat: 0, lng: 0, name: "0", online: true);
  double _heading = 0;

  // _mapViewSites hold the view of map
  // Current a boolean: Site view = True, truck view = flase
  // can be made into sting or list if more views are needed
  bool _mapViewSites = true;

  // _myMapLayers contains the layers for the current map view
  // layers for each views are dynamicly added dependent on current view functionality
  // Typically consist of map tile layer and circle layes for sites
  List<Widget> _myMapLayers = [];

  // Hard coded site details for demontration
  List<SiteLatLng> allSites = [
    SiteLatLng(lat: -25.7479, lng: 28.2293, name: "Pta1", online: true),
    SiteLatLng(lat: -25.6479, lng: 28.4293, name: "Pta2", online: true),
    SiteLatLng(lat: -25.7479, lng: 28.0293, name: "Pta3", online: false),
    SiteLatLng(lat: -25.9479, lng: 28.3293, name: "Pta4", online: true),

    SiteLatLng(lat: -33.9249, lng: 18.4241, name: "Cpt1", online: true),
    SiteLatLng(lat: -33.7249, lng: 18.3241, name: "Cpt2", online: false),
    SiteLatLng(lat: -33.8249, lng: 18.4241, name: "Cpt3", online: false),

    SiteLatLng(lat: 26.8206, lng: 30.8025, name: "Egt1", online: true),
    SiteLatLng(lat: 26.9206, lng: 30.9025, name: "Egt2", online: false),
    SiteLatLng(lat: 26.7206, lng: 30.4025, name: "Egt3", online: true),
    SiteLatLng(lat: 26.3206, lng: 30.8025, name: "Egt4", online: false),
    SiteLatLng(lat: 26.6206, lng: 30.7025, name: "Egt5", online: true),
  ];

  // Hard coded truck details for demontration
  List<SiteLatLng> allTrucks = [
    SiteLatLng(lat: -26.7479, lng: 29.2293, name: "RU101", online: true),
    SiteLatLng(lat: -30.9249, lng: 19.4241, name: "RU102", online: false),
    SiteLatLng(lat: 25.8206, lng: 31.8025, name: "RU103", online: true),
    SiteLatLng(lat: -23.7479, lng: 28.2293, name: "RU104", online: true),
    SiteLatLng(lat: -33.9249, lng: 20.4241, name: "RU105", online: false),
    SiteLatLng(lat: 22.8206, lng: 28.8025, name: "RU106", online: true),
    SiteLatLng(lat: -26.7479, lng: 29.2293, name: "RU107", online: true),
    SiteLatLng(lat: -30.9249, lng: 19.4241, name: "RU108", online: false),
    SiteLatLng(lat: 25.8206, lng: 31.8025, name: "RU109", online: true),
    SiteLatLng(lat: -23.7479, lng: 28.2293, name: "RU110", online: true),
    SiteLatLng(lat: -33.9249, lng: 20.4241, name: "RU111", online: false),
    SiteLatLng(lat: 22.8206, lng: 28.8025, name: "RU112", online: true),
    
  ];
  
  // allCircles: List that contains all circles in circle layer
  List<CircleMarker> allCircles = [];

  // siteContainers: Used to hold all sites that is displayed in right 
  // side search bar
  List<Container> siteContainers = [];

  // _timer: contains times used to update truck locations
  // only used for demo 
  late final Timer _timer;

  // latChange,lngChange: Hold the amount the truck will move in between 
  // timer ticks
  List<double> latChange = [];
  List<double> lngChange = [];
  

  // generates listview widget while searching
  void _buildListView(BuildContext context, String query) {
    siteContainers = [];  
    int listLength = 0;
    
    if (_mapViewSites){
      listLength = allSites.length;
    } else {
      listLength = allTrucks.length;
    }
    
    for (int i = 0; i < listLength; i++) {
      double lat = 0;
      double lng = 0;
      double zoomLvl = 0;
      String name = "";

      if (_mapViewSites){
        lat = allSites[i].lat;
        lng = allSites[i].lng;
        zoomLvl = 6;
        name = allSites[i].name;
      } else {
        lat = allTrucks[i].lat;
        lng = allTrucks[i].lng;
        zoomLvl = 15;
        name = allTrucks[i].name;
      }

      
      if (query.isNotEmpty) {
        // Add sites to listview list based on query value
        if (name.contains(query)){
          siteContainers.add(
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                color: Colors.grey,
              ),
              child: SizedBox.expand(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                    shape: LinearBorder()
                  ),
                  onPressed: () {
                    if (!_mapViewSites){
                      _mapController.move(LatLng(allTrucks[i].lat, allTrucks[i].lng), zoomLvl);
                      _liveTruckName = allTrucks[i];
                    } else {
                      _mapController.move(LatLng(allSites[i].lat, allSites[i].lng), zoomLvl);
                    }
                  },
                  child: Text(name), 
                )
              ),
            )
          );
        }
      } else {
        // Add all sites
        siteContainers.add(
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: Colors.grey,
            ),
            child: SizedBox.expand(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(
                    color: Colors.grey,
                  ),
                  shape: LinearBorder()
                ),
                onPressed: () {
                  if (!_mapViewSites){
                      _mapController.move(LatLng(allTrucks[i].lat, allTrucks[i].lng), zoomLvl);
                      _liveTruckName = allTrucks[i];
                    } else {
                      _mapController.move(LatLng(allSites[i].lat, allSites[i].lng), zoomLvl);
                    }
                },
                child: Text(name), 
              )
            ),
          )
        );
      }
    }

    // Check if no sites were found and add message
    if (siteContainers.isEmpty){
      SiteLatLng emptySite =  SiteLatLng(lat: 0, lng: 0, name: "Nothing Found", online: false);
      siteContainers.add(
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: Colors.grey,
            ),
            child: SizedBox.expand(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(
                    color: Colors.grey,
                  ),
                  shape: LinearBorder()
                ),
                onPressed: () {
                    _mapController.move(LatLng(emptySite.lat, emptySite.lng), 3);
                },
                child: Text(emptySite.name), 
              )
            ),
          )
        );
    }
      
  
  }

  // _centreMapView: centers map 
  void _centreMapView(){
    List<double> allLat = [];
    List<double> allLng = [];
    for (var i = 0; i < allSites.length; i++){
      double lat = allSites[i].lat;
      double lng = allSites[i].lng;
      final String name = allSites[i].name;
      allLat.add(lat);
      allLng.add(lng);
    }

    allLat.sort();
    allLng.sort();
    double lat_min = allLat[0];
    double lat_max = allLat[allLat.length-1];
    double lng_min = allLng[0];
    double lng_max = allLng[allLng.length-1];
    centreLat = lat_min + (lat_max - lat_min)/2;
    centreLng = lng_min + (lng_max - lng_min)/2;

    double zoomDistance = lat_max - lat_min;
    if (zoomDistance < lng_max - lng_min) {
      zoomDistance = lng_max - lng_min;
    }
    double logBase(num x, num base) => log(x) / log(base);
    double log2(num x) => logBase(x, 2);
    intZoomLevel = log2(360/zoomDistance);
    intZoomLevel += intZoomLevel*0.1;
    if (intZoomLevel < 0) {
      intZoomLevel = 0;
    }
    
  }

  // generates Map view for sites or trucks
  void _buildMapView(BuildContext context,) {
    _myMapLayers = [];
    if (_mapViewSites) { 
      _myMapLayers.add(
        TileLayer(
          wmsOptions: WMSTileLayerOptions(
            baseUrl: 'https://{s}.s2maps-tiles.eu/wms/?',
            layers: const ['s2cloudless-2021_3857'],
          ),
          subdomains: const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          tileProvider: CancellableNetworkTileProvider(),
        ),
      );
      _myMapLayers.add(
        CircleLayer(
          circles: allCircles.sublist(0)
        ),
      );
 
    } else {
      _myMapLayers.add(
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          tileProvider: CancellableNetworkTileProvider(),
        ),
      );
      if (_liveTruck){
        _myMapLayers.add(
          CurrentLocationLayer(
            positionStream: _positionStreamController.stream,
            headingStream: _headingStreamController.stream,
          ),
        );
      } else {
        _myMapLayers.add(
          CircleLayer(
            circles: allCircles.sublist(0)
          ),
        );
      }

    }
  }

  // generates all markers to be displayed on map view
  void _fillCircleList(BuildContext context,){
    allCircles = [];

    if (_mapViewSites){
      for (var i = 0; i < allSites.length; i++){
        double lat = allSites[i].lat;
        double lng = allSites[i].lng;
        final String name = allSites[i].name;

        if (allSites[i].online){
          allCircles.add(
            CircleMarker(
              point: LatLng(lat, lng),
              color: Colors.green.withOpacity(0.9),
              borderColor: Colors.black,
              borderStrokeWidth: 2,
              useRadiusInMeter: false,
              radius: 6, 
            )
          );
        } else {
          allCircles.add(
            CircleMarker(
              point: LatLng(lat, lng),
              color: Colors.red.withOpacity(0.9),
              borderColor: Colors.black,
              borderStrokeWidth: 2,
              useRadiusInMeter: false,
              radius: 6, 
            )
          );
        }
      }
    } else {
      for (var i = 0; i < allTrucks.length; i++){
        double lat = allTrucks[i].lat;
        double lng = allTrucks[i].lng;
        final String name = allTrucks[i].name;

        allCircles.add(
          CircleMarker(
            point: LatLng(lat, lng),
            color: Colors.black12.withOpacity(0.9),
            borderColor: Colors.black,
            borderStrokeWidth: 2,
            useRadiusInMeter: false,
            radius: 6, 
          )
        );
      }
    }

    if (allCircles.isEmpty){
      allCircles.add(
        CircleMarker(
          point: LatLng(centreLat, centreLng),
          color: Colors.black.withOpacity(0.9),
          borderColor: Colors.black,
          borderStrokeWidth: 2,
          useRadiusInMeter: false,
          radius: 5, 
        )
      );
    }

  }

  // Demonstrates how the truck icons will move
  void _moveTruckMarkers(BuildContext context,) {
    for (int i = 0; i < allTrucks.length; i++){
      latChange[i] = latChange[i] + (Random().nextDouble() - 0.5) * 0.0001;
      lngChange[i] = lngChange[i] + (Random().nextDouble() - 0.5) * 0.0001;
      allTrucks[i].lat = allTrucks[i].lat + latChange[i];
      allTrucks[i].lng = allTrucks[i].lng + lngChange[i];
    }
  }

  // Update live truck location and heading of truck
  void _updateLiveTruck(BuildContext context,) {
    double lat1 = degToRadian(_currentLat);
    double lon1 = degToRadian(_currentLng);
    double lat2 = degToRadian(_liveTruckName.lat);
    double lon2 = degToRadian(_liveTruckName.lng);
    double dlon = lon2 - lon1;
    
    double x = sin(lat2)*cos(dlon);
    double y = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(dlon);
    double b = atan2(x, y);
   
    
    _heading = (atan2(x, y) / pi) * 180;
    if (_heading < 0){
      _heading += 360;
    }


    _currentLat = _liveTruckName.lat;
    _currentLng = _liveTruckName.lng;
    _positionStreamController.add(
      LocationMarkerPosition(
        latitude: _currentLat,
        longitude: _currentLng,
        accuracy: 0,
      ),
    );
    _headingStreamController.add(
      LocationMarkerHeading(
        heading: degToRadian(_heading),
        accuracy: pi * 0.2,
      ),
    );
  }

  // Build Floading button for map 
  Widget _buildFloatingButton(BuildContext context,) {
    Widget button_icon;
    if (_mapViewSites){
      button_icon = Icon(Icons.center_focus_weak);
    } else {
      button_icon = Icon(Icons.navigation);
    }

    return 
      FloatingActionButton(
        onPressed: () {
          if (_mapViewSites){
            // Centres map to active sites
            _centreMapView();
            _mapController.move(LatLng(centreLat, centreLng), intZoomLevel);
            _buildMapView(context);
            
          } else {
            // Focus map on pre-selected truck
            if (_liveTruck) {
              _liveTruck = false;
              _buildMapView(context);
              _positionStreamController.close();
              _headingStreamController.close();
            } else {
              
              if (!_positionStreamController.hasListener) {
                _positionStreamController = StreamController();
              }
              if (!_headingStreamController.hasListener) {
                _headingStreamController = StreamController();
              }
              _liveTruck = true;
              _buildMapView(context);
            }
          }
        },
        child: button_icon,
      );
  }


  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _centreMapView();
    _fillCircleList(context);
    _buildListView(context, "");
    _buildMapView(context);

    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_mapViewSites){
        setState(() {
          _moveTruckMarkers(context);
          if (_liveTruck){
            _updateLiveTruck(context);
          }
          _fillCircleList(context);
          _buildMapView(context);
        });
      }
    });

    for (int i = 0; i < allTrucks.length; i++){
      latChange.add(0.0);
      lngChange.add(0.0);
    }

  }

  @override
  void dispose() {
    _timer.cancel();
    _positionStreamController.close();
    _headingStreamController.close();
    super.dispose();
    
  }

  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Row( 
        children: [
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: 50,
                  color: Color.fromARGB(255, 6, 45, 77),
                  child: Row(
                    children: [
                      SizedBox(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: LinearBorder()
                          ),
                          onPressed: () {
                            setState(() {
                              _mapViewSites = true;
                              _fillCircleList(context);
                              _buildMapView(context);
                              _buildListView(context, "");
                            });
                          },
                          child: Text("Sites"), 
                        )
                      ),
                      SizedBox(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: LinearBorder()
                          ),
                          onPressed: () {
                            setState(() {
                              _mapViewSites = false;
                              _fillCircleList(context);
                              _buildMapView(context);
                              _buildListView(context, "");
                            });
                          },
                          child: Text("Trucks"), 
                        )
                      ),
                    ],
                  )
                ),
    
                Expanded(
                  child: Scaffold(
                    floatingActionButton: _buildFloatingButton(context),
                    body: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(centreLat, centreLng),
                        initialZoom: intZoomLevel,
                        cameraConstraint: CameraConstraint.contain(
                          bounds: LatLngBounds(
                            const LatLng(-90, -180),
                            const LatLng(90, 180),
                          ),
                        ),
                      ),
                      children: _myMapLayers.sublist(0),
                    ),
                  )
                  
                  
                ),
                Container(
                  height: 50,
                  color: Color.fromARGB(255, 6, 45, 77),
                ),
              ]  
            ) 
          ),

          SizedBox(
            width: 300,
            child: Column(
              children: <Widget>[
                Container(
                  height: 50,
                  color: Colors.blueGrey,
                  child: Center(
                    child: TextFormField(
                      controller: textControllerSite,
                      decoration: InputDecoration(
                        labelText: "Enter Site Name",
                      ),
                      onChanged: (value) {
                        setState(() {
                          _buildListView(context, value);
                        });
                      } 
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey,
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: siteContainers.sublist(0),
                    ),
                    
                  )
                  
                ),
              ],
            )
          )
        ]
      )
    );
  }
}

