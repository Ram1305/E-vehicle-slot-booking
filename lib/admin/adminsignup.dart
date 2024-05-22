import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adminlogin.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _signUpInProgress = false;

  void _validateEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    setState(() {
      _isEmailValid = emailRegExp.hasMatch(email);
    });
  }

  void _validatePassword(String password) {
    final passwordRegExp =
    RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[\W_]).{8,}$');
    setState(() {
      _isPasswordValid = passwordRegExp.hasMatch(password);
    });
  }

  void _signUpWithEmailAndPassword(
      String shopName, // Changed parameter name
      String email,
      String password,
      ) async {
    if (shopName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your shop name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _signUpInProgress = true;
    });

    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _saveUserDataToFirestore(
          shopName, // Changed parameter name
          email,
          password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up successful!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
        ),
      );

      print('Error signing up: $errorMessage');
    } finally {
      setState(() {
        _signUpInProgress = false;
      });
    }
  }

  Future<void> _saveUserDataToFirestore(
      String shopName, // Changed parameter name
      String email,
      String password,
      ) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('Admin').doc(uid).set({
          'shopName': shopName, // Changed key
          'email': email,
          'password': password,
        });
        print(
            'User data saved to Firestore: $email, $password, $shopName');
      }
    } catch (e) {
      print('Error saving user data to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 100),
              Text(
                'Getting Started',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Sign Up And',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Join  Now',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 80),
              TextField(
                controller: _shopNameController,
                decoration: InputDecoration(
                  labelText: 'Bunk Name', // Changed label
                  labelStyle: TextStyle(
                    color: Colors.blueAccent,
                  ),
                  prefixIcon: Icon(
                    Icons.electric_bike_sharp,
                    color: Colors.blueAccent,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                ),
              ),
              SizedBox(height: 22),
              TextField(
                controller: _emailController,
                onChanged: _validateEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.blueAccent,
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.blueAccent,
                  ),
                  errorText: _isEmailValid ? null : 'Invalid email format',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 22),
              TextField(
                controller: _passwordController,
                onChanged: _validatePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.blueAccent,
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.blueAccent,
                  ),
                  errorText: _isPasswordValid ? null : 'Password must be...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _signUpInProgress
                    ? null
                    : () => _signUpWithEmailAndPassword(
                  _shopNameController.text,
                  _emailController.text,
                  _passwordController.text,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminlogScreen()),
                    );
                  },
                  child: Text('Already have an Account... click here to Login ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
