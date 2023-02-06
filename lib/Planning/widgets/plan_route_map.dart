import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sekkah_app/constants/app_icons.dart';
import 'package:sekkah_app/core/const.dart';

class PlanRouteMap extends StatefulWidget {
  const PlanRouteMap({
    Key? key,
    required this.originLatLong,
    required this.destinationLatLong,
  }) : super(key: key);

  final List originLatLong;
  final List destinationLatLong;

  @override
  State<PlanRouteMap> createState() => _PlanRouteMapState();
}

class _PlanRouteMapState extends State<PlanRouteMap> {
  GoogleMapController? mapController;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Marker> _markers = {};

  @override
  void initState() {
    _getPolyline();
    setMapPins();
    super.initState();
    
  }

  // void _onMapCreated(GoogleMapController controller) async {
  //   mapController = controller;
  // }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        width: 5,
        polylineId: id,
        color: Colors.grey,
        patterns: [PatternItem.dash(30), PatternItem.gap(20)],
        points: polylineCoordinates);

    polylines[id] = polyline;
    setState(() {});
  }


  _getPolyline() async {
    if (widget.originLatLong.isNotEmpty &&
        widget.destinationLatLong.isNotEmpty) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Const.apiKey,
        PointLatLng(widget.originLatLong[0], widget.originLatLong[1]),
        PointLatLng(widget.destinationLatLong[0], widget.destinationLatLong[1]),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
    }
    _addPolyLine();

  }

  void setMapPins() async  {
    _markers.add(Marker(
        icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(150.h, 150.h)), AppIcons.myloc),
        markerId: const MarkerId('sourcePin'),
        position: LatLng(widget.originLatLong[0], widget.originLatLong[1]),
      ));
      // destination pin
      _markers.add(Marker(
        icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(280.h, 280.h)), AppIcons.des),
        markerId: const MarkerId('destPin'),
       
        position:
            LatLng(widget.destinationLatLong[0], widget.destinationLatLong[1]),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target:
            widget.originLatLong.isEmpty && widget.destinationLatLong.isEmpty
                ? const LatLng(24.71619956670347, 46.68385748947401)
                : LatLng(
                    widget.originLatLong[0],
                    widget.originLatLong[1],
                  ),
        zoom: 11,
      ),
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      polylines: Set<Polyline>.of(polylines.values),
      markers: Set<Marker>.of(_markers),
    );
  }
}