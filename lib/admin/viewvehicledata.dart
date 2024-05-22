import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDataPage extends StatefulWidget {
  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<ViewDataPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteZone(String documentId) async {
    try {
      await _firestore.collection('Zones').doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zone deleted successfully!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting zone: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

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

              return ListTile(
                title: Text('Zone Details: ${data['Zone details']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: ${data['address']}'),
                    Text('Latitude: ${data['latitude']}'),
                    Text('Longitude: ${data['longitude']}'),
                    Text('UID: ${data['uid']}'),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(data['imageUrl']),
                      ),
                    ),
                  ],
                ),

                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Zone?'),
                          content: Text('Are you sure you want to delete this zone?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Delete the zone and close the dialog
                                _deleteZone(zones[index].id);
                                Navigator.pop(context);
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
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
}
