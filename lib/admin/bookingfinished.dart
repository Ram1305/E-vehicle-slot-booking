import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingFinished extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finished Bookings'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('bookingfinished').snapshots(),
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
                    SizedBox(height: 10),
                    Divider(height: 10, thickness: 2, color: Colors.cyan),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
