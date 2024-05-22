import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evehicle/admin/bookingdata.dart';
import 'package:evehicle/admin/bookingfinished.dart';
import 'package:evehicle/admin/openandclose.dart';
import 'package:evehicle/admin/profile.dart';
import 'package:evehicle/admin/vehicledataupload.dart';
import 'package:evehicle/admin/viewvehicledata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class Entry extends StatefulWidget {
  final String userId;

  Entry({required this.userId});

  @override
  _EntryState createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  String? userName;
  String? userEmail;
  String? profilePictureURL;

  Future<void> _fetchRestaurantDetails() async {
    try {
      final restaurantDoc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(widget.userId)
          .get();

      if (restaurantDoc.exists) {
        final data = restaurantDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = data['shopName'] as String?;
          userEmail = data['email'] as String?;
          profilePictureURL = data['profilePictureURL'] as String?;
        });
      }
    } catch (e) {
      print('Error fetching restaurant details: $e');
    }
  }

  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imageName = '${widget.userId}_profile_image';
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('profile_images/$imageName');

      UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('Admin')
          .doc(widget.userId)
          .update({'profilePictureURL': downloadURL});

      setState(() {
        profilePictureURL = downloadURL;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRestaurantDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(' E-vehicle Slot Admin'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminUpload()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .blueAccent,
              ),
              child: Text('Upload Zone Data',style: TextStyle(color: Colors.white,)),
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewDataPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .blueAccent,
              ),
              child: Text('View Zone data',style: TextStyle(color: Colors.white,)),
            ),
            SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => openPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .blueAccent,
              ),
              child: Text('opening and closing data',style: TextStyle(color: Colors.white,)),
            ),

            SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingDetails()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .blueAccent,
              ),
              child: Text('Waiting List',style: TextStyle(color: Colors.white,)),
            ),
            // Show the profile picture
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userName ?? 'Unknown Restaurant'),
              accountEmail: Text(userEmail ?? 'No Email'),
              currentAccountPicture: Stack(
                children: [
                  Container(
                    width: 250,
                    height: 200,
                    child: profilePictureURL != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(profilePictureURL!),
                    )
                        : Icon(
                      Icons.camera,
                      size: 40,
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.electric_bike),
              title: Text('Vehicle Zone'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewDataPage()),
                );
              },
            ),


            ListTile(
              leading: Icon(Icons.nest_cam_wired_stand_outlined),
              title: Text('Waiting list'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingDetails()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Booking History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingFinished()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacementNamed(context, '/login');
}
