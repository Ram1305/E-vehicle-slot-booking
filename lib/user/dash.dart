import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:evehicle/user/bookdetails.dart';
import 'package:evehicle/user/userbook.dart';
import 'package:evehicle/user/userprofile.dart';
import 'package:evehicle/user/userzone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Userdash extends StatefulWidget {
  final String userId;

  Userdash({required this.userId});

  @override
  _UserdashState createState() => _UserdashState();
}

class _UserdashState extends State<Userdash> {
  String? username;
  String? userEmail;
  String? profilePictureURL;

  @override
  void initState() {
    super.initState();
    _initializeUserDetails();
  }

  Future<void> _initializeUserDetails() async {
    await _fetchRestaurantDetails();
  }

  Future<void> _fetchRestaurantDetails() async {
    try {
      if (widget.userId != null && widget.userId.isNotEmpty) {
        final restaurantDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.userId)
            .get();

        if (restaurantDoc.exists) {
          final data = restaurantDoc.data() as Map<String, dynamic>;

          final fetchedUsername = data['username'] as String?;
          final fetchedUserEmail = data['email'] as String?;

          print('Fetched Username: $fetchedUsername');
          print('Fetched User Email: $fetchedUserEmail');

          setState(() {
            username = fetchedUsername ?? 'Unknown username';
            userEmail = fetchedUserEmail ?? 'No Email';
            profilePictureURL = data['profilePictureURL'] as String?;
          });
        } else {
          print('Document does not exist for userId: ${widget.userId}');
        }
      } else {
        print('Invalid userId: ${widget.userId}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
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

      await FirebaseFirestore.instance.collection('user').doc(widget.userId).update({
        'profilePictureURL': downloadURL,
        'username': username, // Add this line to update the username
      });

      setState(() {
        profilePictureURL = downloadURL;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(' E-vehicle Slot Booking'),
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
                  MaterialPageRoute(builder: (context) => userViewzonePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .blueAccent,
              ),
              child: Text('View Zone data',style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => userbookzonePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .blueAccent,
              ),
              child: Text('Book slot data',style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingDetailsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .blueAccent,
              ),
              child: Text('Booking details',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(username ?? ''),
              accountEmail: Text(userEmail ?? ''),
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
              title: Text('Vehicle list'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => userProfilePage(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Booking History'),
              onTap: () {
                Navigator.pop(context);
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
