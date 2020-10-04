
import "dart:async";
import "package:http/http.dart" as http;
import "dart:convert";
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:permission/permission.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import "package:google_map_polyline/google_map_polyline.dart";
// import 'package:flutter_map/flutter_map.dart';



  


class Routes extends StatefulWidget {
  final String ph;
  final double lat;
  final double long;
  var currentLocation;
  Routes({this.lat,this.long,this.currentLocation,this.ph});
  @override
  _RoutesState createState() => _RoutesState(lat,long,currentLocation,ph);
}
const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class _RoutesState extends State<Routes> {
  final double lat;
  final double long;
  final String ph;
  LocationData currentLocation;
  _RoutesState(this.lat,this.long,this.currentLocation,this.ph);
Completer<GoogleMapController> _controller = Completer();
    Set<Marker> _markers = {};
        Set<Polyline> _polylines = {};
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    String googleAPIKey = "*************";

    @override
    void initState() {
      super.initState();
    }



    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
                  children:[ GoogleMap(
          myLocationEnabled: true,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          markers: _markers,
          polylines: _polylines,
          mapType: MapType.normal,
          initialCameraPosition:  CameraPosition(target: LatLng(currentLocation.latitude,currentLocation.longitude), zoom: 14.0),
          onMapCreated: onMapCreated),
           (ph!=null)?
    Container(
      height: double.infinity,
      width: double.infinity,
     child: Container(
       alignment:Alignment(0.85, 0.6),
       child:
         IconButton(icon: 
         Icon(Icons.phone,
         color: Colors.green,
         size:60),
          onPressed: (){
            print(ph);
            launch("tel:$ph");
          } )
      )
    ):
    Container()
          ]
        ),
      );
    }
    void onMapCreated(GoogleMapController controller) {
      _controller.complete(controller);
      setMapPins();
      setPolylines();
    }

    void setMapPins() {
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('destPin'),
            position: LatLng(lat,long),
            icon: BitmapDescriptor.defaultMarker));
      });
    }
    @override
     Future<List<PointLatLng>> getRouteBetweenCoordinates(String googleApiKey, double originLat, double originLong,
      double destLat, double destLong)async
  {
    List<PointLatLng> polylinePoints = [];
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=" +
        originLat.toString() +
        "," +
        originLong.toString() +
        "&destination=" +
        destLat.toString() +
        "," +
        destLong.toString() +
        "&mode=walking" +
        "&key=$googleApiKey";
    var response = await http.get(url);
    try {
      if (response?.statusCode == 200) {
        polylinePoints = decodeEncodedPolyline(json.decode(
            response.body)["routes"][0]["overview_polyline"]["points"]);
      }
    } catch (error) {
      throw Exception(error.toString());
    }
    print(polylinePoints);
    return polylinePoints;
  }


  List<PointLatLng> decodeEncodedPolyline(String encoded)
  {
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      PointLatLng p = new PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }


    setPolylines() async {

        List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
            googleAPIKey,
            currentLocation.latitude,
            currentLocation.longitude,
            lat,
            long);
        if (result.isNotEmpty) {
          result.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }

      setState(() {
          Polyline polyline = Polyline(
              polylineId: PolylineId("poly"),
              color: Colors.blue,
              endCap: Cap.buttCap,
              startCap: Cap.roundCap,
              patterns: [PatternItem.dot],
              points: polylineCoordinates);
          _polylines.add(polyline);
      });
  }
}


