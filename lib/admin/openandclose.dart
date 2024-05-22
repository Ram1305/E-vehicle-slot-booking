import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class openPage extends StatefulWidget {
  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<openPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

          return ListView.builder(
            itemCount: zones.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = zones[index].data() as Map<String, dynamic>;

              bool switchValue = data['switchValue'] ?? false; // Retrieve switch value from Firestore

              return ListTile(
                leading: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['imageUrl']),
                  ),
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
                trailing: Switch(
                  value: switchValue,
                  onChanged: (value) {
                    // Handle switch state change
                    _updateSwitchValue(zones[index].id, value);

                    // Perform any additional actions based on the switch state change
                    // ...
                  },
                ),
                onTap: () {
                  // Navigate to the specific zone for viewing
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateSwitchValue(String documentId, bool value) async {
    await _firestore.collection('Zones').doc(documentId).update({
      'switchValue': value,
    });
  }
}
