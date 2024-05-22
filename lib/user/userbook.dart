import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class userbookzonePage extends StatefulWidget {
  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<userbookzonePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _launchingGoogleMaps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Data'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('Zones').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> zones = snapshot.data!.docs;
          List<DocumentSnapshot> filteredZones =
          zones.where((zone) => zone['switchValue'] == true).toList();

          return ListView.builder(
            itemCount: filteredZones.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
              filteredZones[index].data() as Map<String, dynamic>;

              double latitude = double.tryParse(data['latitude'] ?? '') ?? 0.0;
              double longitude =
                  double.tryParse(data['longitude'] ?? '') ?? 0.0;

              return ListTile(
                contentPadding: EdgeInsets.all(8.0),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data['imageUrl']),
                  radius: 25,
                ),
                title: Text('Zone Details: ${data['Zone details']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: ${data['address']}'),
                    Text('Latitude: ${data['latitude']}'),
                    Text('Longitude: ${data['longitude']}'),
                  ],
                ),
                trailing: _launchingGoogleMaps
                    ? CircularProgressIndicator()
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.directions, color: Colors.blue),
                      onPressed: () async {
                        if (latitude != null && longitude != null) {
                          setState(() {
                            _launchingGoogleMaps = true;
                          });

                          await _launchMapView(latitude, longitude);

                          setState(() {
                            _launchingGoogleMaps = false;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Invalid latitude or longitude'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showBookingDialog(data);
                      },
                      child: Text('Book'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _launchMapView(double latitude, double longitude) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapScreen(latitude: latitude, longitude: longitude),
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> zoneData) {
    String enteredName = '';
    String enteredMobileNumber = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book Slot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  enteredName = value;
                },
              ),
              TextField(
                decoration:
                InputDecoration(labelText: 'Mobile Number'),
                onChanged: (value) {
                  enteredMobileNumber = value;
                },
              ),
              ListTile(
                title: Text('Date: ${selectedDate.toLocal()}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 1),
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Time: ${selectedTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );

                  if (pickedTime != null && pickedTime != selectedTime) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _bookSlot(
                  zoneData,
                  enteredName,
                  enteredMobileNumber,
                  selectedTime,
                  selectedDate,
                );
                Navigator.pop(context);
              },
              child: Text('Book'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _bookSlot(
      Map<String, dynamic> zoneData,
      String enteredName,
      String enteredMobileNumber,
      TimeOfDay selectedTime,
      DateTime selectedDate,
      ) {
    // Get the current user ID
    String userId = getCurrentUserId();

    FirebaseFirestore.instance.collection('slotbookdetails').add({
      'zoneDetails': {
        'zoneName': zoneData['Zone details'],
        'address': zoneData['address'],
        'imageUrl': zoneData['imageUrl'],
        'latitude': zoneData['latitude'],
        'longitude': zoneData['longitude'],
        'switchValue': zoneData['switchValue'],
        'uid': zoneData['uid'],
      },
      'name': enteredName,
      'mobileNumber': enteredMobileNumber,
      'timing': '${selectedTime.hour}:${selectedTime.minute}',
      'date': selectedDate.toLocal(),
      'userId': userId,
      // Add other necessary details
    });
  }

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }
}

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  MapScreen({required this.latitude, required this.longitude});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 15.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _mapController = controller;
          });
        },
        markers: {
          Marker(
            markerId: MarkerId('Target'),
            position: LatLng(widget.latitude, widget.longitude),
            infoWindow: InfoWindow(title: 'Target Location'),
          ),
        },
      ),
    );
  }
}
