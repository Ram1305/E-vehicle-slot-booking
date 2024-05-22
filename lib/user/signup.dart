import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evehicle/user/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isUsernameValid = true;

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _signUpInProgress = false;
  String? _passwordErrorText;
  void _validateUsername(String username) {
    final usernameRegExp = RegExp(r'^[a-zA-Z]+$');
    setState(() {
      _isUsernameValid = usernameRegExp.hasMatch(username);
    });
  }

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
      _isPasswordValid =
          password.isNotEmpty && passwordRegExp.hasMatch(password);
    });

    if (password.isNotEmpty) {
      if (!passwordRegExp.hasMatch(password)) {
        setState(() {
          _passwordErrorText = ' please enter your password';
        });
      } else {
        setState(() {
          _passwordErrorText = ' password must be 8 character';
        });
      }
    } else {
      setState(() {
        _passwordErrorText = 'Password  okk';
      });
    }
  }

  void _validateConfirmPassword(String confirmPassword) {
    setState(() {
      _isConfirmPasswordValid = _passwordController.text == confirmPassword;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _signUpWithEmailAndPassword(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
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
          username,
          email,
          password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up successful!'),
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      // Show error message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email or Password is wrong or already registered?.'),
          duration: Duration(seconds: 3),
        ),
      );

      print('Error signing up: $e');
    } finally {
      setState(() {
        _signUpInProgress = false;
      });
    }
  }

  Future<void> _saveUserDataToFirestore(
      String username, String email, String password) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('user').doc(uid).set({
          'username': username,
          'email': email,
          'password': password,
        });
        print('User data saved to Firestore: $email, $password');
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
              SizedBox(
                height: 150,

              ),
              Image.asset(
                "assets/e.png", // Replace with your image asset path
                height: 150, // Adjust the height as needed
              ),
              SizedBox(
                height: 20,
              ),
              Text('Sign Up',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  )),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _usernameController,
                onChanged: _validateUsername,
                decoration: InputDecoration(
                  labelText: 'username',
                  labelStyle: TextStyle(
                    color: Colors.greenAccent,
                  ),
                  errorText: _isUsernameValid
                      ? null
                      : 'Please enter your username', // Display error text if not valid
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.greenAccent,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                onChanged: _validateEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.greenAccent,
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.greenAccent,
                  ),
                  errorText: _isEmailValid
                      ? null
                      : 'please enter valid email ex.abc@gmail.com.',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.greenAccent), // Outline border color
                  ),
                ),
              ),
              SizedBox(height: 22),
              TextField(
                controller: _passwordController,
                onChanged: _validatePassword,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.greenAccent,
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.greenAccent,
                  ),
                  errorText: _isPasswordValid
                      ? null
                      : 'Password contains one uppercase,lowercase letter, one digit, and one special character.',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.greenAccent), // Outline border color
                  ),
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordVisibility,
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22),
              TextField(
                controller: _confirmPasswordController,
                onChanged: _validateConfirmPassword,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(
                    color: Colors.greenAccent,
                  ),
                  errorText: _isConfirmPasswordValid
                      ? null
                      : 'Passwords does not match',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                    // Outline border color
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.greenAccent,
                  ),
                  suffixIcon: IconButton(
                    onPressed: _toggleConfirmPasswordVisibility,
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signUpInProgress
                    ? null
                    : () {
                        if (_usernameController.text.isEmpty) {
                          setState(() {
                            _isUsernameValid = false;
                          });
                        }
                        if (_emailController.text.isEmpty) {
                          setState(() {
                            _isEmailValid = false;
                          });
                        }
                        if (_passwordController.text.isEmpty) {
                          setState(() {
                            _isPasswordValid = false;
                          });
                        }

                        if (_confirmPasswordController.text.isEmpty) {
                          setState(() {
                            _isConfirmPasswordValid = false;
                          });
                        } else {
                          _signUpWithEmailAndPassword(
                            _usernameController.text,
                            _emailController.text,
                            _passwordController.text,
                            _confirmPasswordController.text,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .greenAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  elevation: 3, // Shadow elevation
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
