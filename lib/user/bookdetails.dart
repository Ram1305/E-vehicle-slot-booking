import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingDetailsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('slotbookdetails')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
              bookings[index].data() as Map<String, dynamic>;

              // Format date
              DateTime date = data['date'].toDate();
              String formattedDate = DateFormat.yMd().format(date);

              // Format time
              String formattedTime = data['timing'];

              return ListTile(
                title: Text('Name: ${data['name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobile Number: ${data['mobileNumber']}'),
                    Text('Timing: $formattedTime'),
                    Text('Date: $formattedDate'),
                    SizedBox(height: 8.0),
                    Text('Zone Details:'),
                    Text('Zone Name: ${data['zoneDetails']['zoneName']}'),
                    Text('Address: ${data['zoneDetails']['address']}'),
                    SizedBox(height: 10,),
                    Divider(height: 10,thickness:2,color: Colors.cyan),
                    // Add other zone details as needed
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    _deleteBooking(context, bookings[index].id); // Pass context here
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteBooking(BuildContext context, String bookingId) async { // Include context here
    try {
      await FirebaseFirestore.instance
          .collection('slotbookdetails')
          .doc(bookingId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking cancelled successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking'),
        ),
      );
      print('Error deleting booking: $e');
    }
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
