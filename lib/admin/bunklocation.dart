import 'package:evehicle/admin/vehicledataupload.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';


class locateme extends StatefulWidget {
  @override
  _locatemeScreenState createState() => _locatemeScreenState();
}

class _locatemeScreenState extends State<locateme> {
  final MarkerId defaultMarkerId = MarkerId("currentLocation");
  LatLng? selectedLocation;
  static const LatLng _center = const LatLng(11.0168, 76.9558);

  late GoogleMapController mapController;
  loc.LocationData? currentLocation;

  TextEditingController manualLocationController = TextEditingController();
  String? currentAddress;

  void _onMapCreated(GoogleMapController controller) {
    print('Map created');
    mapController = controller;
  }

  void _handleMapTap(LatLng tappedPoint) {
    print('Map tapped');
    setState(() {
      selectedLocation = tappedPoint;
      _getCurrentAddress();
    });
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    _getCurrentLocation();
  }

  void _requestLocationPermission() async {
    loc.Location location = loc.Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _getCurrentLocation() async {
    print('Getting current location');
    loc.Location location = loc.Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    loc.LocationData _locationData = await location.getLocation();
    setState(() {
      currentLocation = _locationData;
      selectedLocation = LatLng(
        _locationData.latitude ?? 11.0168,
        _locationData.longitude ?? 76.9558,
      );
    });
  }

  void _handleConfirmLocation() {
    if (currentAddress != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminUpload(
            selectedLatitude: selectedLocation?.latitude.toString(),
            selectedLongitude: selectedLocation?.longitude.toString(),
          ),
        ),
      );
    }
  }


  void _getCurrentAddress() async {
    if (selectedLocation != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          selectedLocation!.latitude,
          selectedLocation!.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          setState(() {
            currentAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
            manualLocationController.text = currentAddress ?? '';
          });
        }
      } catch (e) {
        print('Error getting current address: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter your location'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  SizedBox(
                    height: 600,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: selectedLocation ?? _center,
                        zoom: 11.0,
                      ),
                      onTap: _handleMapTap,
                      markers: selectedLocation != null
                          ? {
                        Marker(
                          markerId: defaultMarkerId,
                          position: selectedLocation!,
                          infoWindow:
                          InfoWindow(title: 'My Current Location'),
                        ),
                      }
                          : {},
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (selectedLocation != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Location Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (currentAddress != null) Text('Address: $currentAddress'),
                ],
              ),
            ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: ElevatedButton(
                    onPressed: _handleConfirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: Text(
                      'Confirm my location',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
