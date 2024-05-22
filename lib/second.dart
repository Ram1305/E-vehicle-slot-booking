

import 'package:evehicle/admin/adminlogin.dart';
import 'package:evehicle/admin/adminsignup.dart';
import 'package:evehicle/user/login.dart';
import 'package:evehicle/user/signup.dart';
import 'package:flutter/material.dart';


class Second extends StatefulWidget {
  @override
  _Second createState() => _Second();
}

class _Second extends State<Second> {
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _updateGreeting();
  }

  void _updateGreeting() {
    final currentTime = DateTime.now();
    final currentTimeOfDay = currentTime.hour;
    String newGreeting = '';

    if (currentTimeOfDay >= 0 && currentTimeOfDay < 12) {
      newGreeting = 'Good Morning User';
    } else if (currentTimeOfDay >= 12 && currentTimeOfDay < 17) {
      newGreeting = 'Good Afternoon User';
    } else {
      newGreeting = 'Good Evening User';
    }

    setState(() {
      _greeting = newGreeting;
    });
  }

  void _AdminPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminScreen()),
    );

  }
  void _LoginPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    // Navigate to the next page (replace `NextPage` with your actual page)

  }

  void _SignupPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }
  void _Adminlogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminlogScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset(
                "assets/e.png",
                width: 500,
                height: 500,
              ),
            ),
            Text(
              _greeting,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20), // Adding some space between text and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20), // Adding space below buttons
                Center(
                  child: ElevatedButton(
                    onPressed: _AdminPressed,
                    child: Text('Admin Signup',
                        style: TextStyle(
                          fontSize: 20,color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .blueAccent, // Make button background transparent
                      elevation: 0, // Remove button elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.black), // Add border
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _Adminlogin,
                    child: Text('Admin Login',
                        style: TextStyle(
                          fontSize: 20,color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .blueAccent, // Make button background transparent
                      elevation: 0, // Remove button elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.black), // Add border
                      ),
                    ),
                  ),

                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.redAccent, // Customize the button color
              ),
              child: ElevatedButton(
                onPressed: _SignupPressed,
                child: Text('User Sign Up',
                    style: TextStyle(
                      fontSize: 20,color: Colors.white,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .blueAccent, // Make button background transparent
                  elevation: 0, // Remove button elevation
                ),
              ),

            ),
            SizedBox(height: 20), // Increased space between buttons
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                color: Colors.redAccent, // Customize the button color
              ),
              child: ElevatedButton(
                onPressed: _LoginPressed,
                child: Text(' User Login',
                    style: TextStyle(
                      fontSize: 20,color: Colors.white,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .blueAccent,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),



        ),

    );
  }
}
