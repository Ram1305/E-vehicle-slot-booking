import 'dart:io';


import 'package:evehicle/admin/bunklocation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AdminUpload extends StatefulWidget {
  final String? selectedLatitude;
  final String? selectedLongitude;

  AdminUpload({this.selectedLatitude, this.selectedLongitude});
  @override
  _AdminUploadState createState() => _AdminUploadState();
}

class _AdminUploadState extends State<AdminUpload> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _selectedVehicleType = 'Gandhipuram';
  List<String> _vehicleTypes = [
    'Gandhipuram',
    'Singanallur',
    "Ramanathapuram",
    "Peelamedu",
    "hopecollege",
    "Thudiyalur",
    "Saravanampatti"
  ];
  TextEditingController _addressController = TextEditingController(); // Updated controller name
  XFile? _pickedImage;



  Future<void> _uploadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return; // Only authenticated users can upload data
      }

      String uid = user.uid;
      String vehicleType = _selectedVehicleType;
      String address = _addressController.text;
      String imageUrl = await _uploadImage(); // Use a separate method for image upload

      // Generate a new document ID for each data entry
      await _firestore.collection('Zones').add({
        'uid': uid,
        'Zone details': vehicleType,
        'address': address,

        'imageUrl': imageUrl,
        'latitude': widget.selectedLatitude,
        'longitude': widget.selectedLongitude,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bunk data uploaded successfully!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading bunk data to Firestore: $e'),
          duration: Duration(seconds: 3),
        ),
      );
      print('Error uploading bunk data to Firestore: $e');
    }
  }

  Future<String> _uploadImage() async {
    if (_pickedImage == null) {
      return ''; // No image selected
    }

    try {
      // Upload image to Firebase Storage
      String imagePath = 'images/${DateTime.now().millisecondsSinceEpoch.toString()}';
      await _storage.ref().child(imagePath).putFile(File(_pickedImage!.path));

      // Get download URL
      String imageUrl = await _storage.ref().child(imagePath).getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      throw e;
    }
  }




  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }


  Future<void> _selectLocation() async {
    // Navigate to locateme screen
    String? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => locateme()),
    );


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload User Data'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selectLocation,
              child: Text('Select Location'),
            ),
            DropdownButton<String>(
              value: _selectedVehicleType,
              onChanged: (newValue) {
                setState(() {
                  _selectedVehicleType = newValue!;
                });
              },
              items: _vehicleTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _addressController, // Updated controller
              decoration: InputDecoration(
                  labelText: 'Address'), // Updated label
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Bunk Image'),
            ),
            if (_pickedImage != null)
              Image.file(
                File(_pickedImage!.path),
                height: 100,
                width: 100,
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploadUserData,
              child: Text('Upload Bunk Data - Latitude: ${widget.selectedLatitude}, Longitude: ${widget.selectedLongitude}'),
            ),

          ],
        ),
      ),
    );
  }
}
