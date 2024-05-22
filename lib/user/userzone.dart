import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class userViewzonePage extends StatefulWidget {
  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<userViewzonePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('View Available zone Data'),
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
                    Text('UID: ${data['uid']}'),
                  ],
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
}
