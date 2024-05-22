import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evehicle/admin/admindash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userProfilePage extends StatefulWidget {
  final String userId;
  final Function()? onProfilePictureUpdated;

  userProfilePage({required this.userId, this.onProfilePictureUpdated});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<userProfilePage> {
  String? profilePictureURL;
  bool isUploading = false;
  User? _user;

  Future<void> _uploadProfilePicture(BuildContext context) async {
    setState(() {
      isUploading = true;
    });

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
          .collection('user')
          .doc(widget.userId)
          .update({'profilePictureURL': downloadURL});

      await _saveProfilePictureURL(downloadURL);

      if (widget.onProfilePictureUpdated != null) {
        widget.onProfilePictureUpdated!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload Successful'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        profilePictureURL = downloadURL;
        isUploading = false;
      });
    } else {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _saveProfilePictureURL(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePictureURL', url);
  }

  Future<void> _loadProfilePictureURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loadedURL = prefs.getString('profilePictureURL');
    setState(() {
      profilePictureURL = loadedURL;
    });
  }

  @override
  void initState() {
    super.initState();

    // Get the currently authenticated user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
      });
    }

    _loadProfilePictureURL();
    _loadAndDisplayProfilePicture();
  }

  // Function to load and display the profile picture
  Future<void> _loadAndDisplayProfilePicture() async {
    if (widget.userId == _user?.uid) {
      // Only load and display the profile picture if it's the user's own profile
      final snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final profileURL = userData['profilePictureURL'] as String?;
        if (profileURL != null) {
          setState(() {
            profilePictureURL = profileURL;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = widget.userId == _user?.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 250,
                height: 200,
                child: profilePictureURL != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(
                    '$profilePictureURL?${DateTime.now().millisecondsSinceEpoch}',
                  ),
                )
                    : isCurrentUser
                    ? Icon(
                  Icons.camera_alt,
                  size: 40,
                )
                    : SizedBox(), // Hide profile picture for other users
              ),
              SizedBox(height: 16),
              Text(
                'Hello, ${_user?.displayName ?? 'User'}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Email: ${_user?.email ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              if (isCurrentUser) // Show upload button only for the current user
                ElevatedButton(
                  onPressed: () async {
                    _uploadProfilePicture(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: Text('Upload Profile Picture'),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Entry(
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: Text('Sign Out',style: TextStyle(color: Colors.white,),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
