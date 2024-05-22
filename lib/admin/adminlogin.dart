import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evehicle/admin/admindash.dart';
import 'package:evehicle/admin/adminsignup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';




class AdminlogScreen extends StatefulWidget {
  @override
  _AdminlogScreenState createState() => _AdminlogScreenState();
}

class _AdminlogScreenState extends State<AdminlogScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _loginInProgress = false;

  void _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
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

  Future<void> _loginWithEmailAndPassword(
      String email,
      String password,
      ) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _loginInProgress = true;
    });

    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_auth.currentUser != null) {
        String userId = _auth.currentUser!.uid;
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('Admin')
            .doc(userId)
            .get();

        if (adminDoc.exists) {
          String shopName = adminDoc.get('shopName'); // Updated variable name
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Entry(userId: userId)),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging in. Please check your data.'),
          duration: Duration(seconds: 3),
        ),
      );

      print('Error logging in: $e');
    } finally {
      setState(() {
        _loginInProgress = false;
      });
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
              SizedBox(
                height: 85,
              ),
              Text('Welcome Back ',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(
                height: 30,
              ),
              Text('Admin Login',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(
                height: 50,
              ),
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
              SizedBox(height: 32),
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
                  errorText: _isPasswordValid
                      ? null
                      : 'Password must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one digit, and one special character.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 34),
              ElevatedButton(
                onPressed: _loginInProgress
                    ? null
                    : () => _loginWithEmailAndPassword(
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
                  'Login',
                  style: TextStyle(
                    fontSize: 18,color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminScreen()),
                    );
                  },
                  child: Text('Dont have an Account ?    SIGNUP ',
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
