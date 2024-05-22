import 'package:evehicle/user/dash.dart';
import 'package:evehicle/user/forgot.dart';
import 'package:evehicle/user/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _obscurePassword = true;
  bool _showEmailError = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');
    if (userEmail != null && userEmail.isNotEmpty) {
      setState(() {
        _emailController.text = userEmail;
      });
    }
  }

  void _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    setState(() {
      _isEmailValid = emailRegExp.hasMatch(email);
      _showEmailError = !_isEmailValid && email.isNotEmpty;
    });
  }

  void _validatePassword(String password) {
    final passwordRegExp =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[\W_]).{8,}$');
    setState(() {
      _isPasswordValid = passwordRegExp.hasMatch(password);
    });
  }

  void _login() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _showEmailError = true;
      });
      return;
    }

    if (_isEmailValid && _isPasswordValid) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          User user = userCredential.user!;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Userdash(userId: '',

                )),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please check your email and password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('waste if tune');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 150,
                ),
                Image.asset(
                  "assets/e.png",
                  height: 150,
                ),
                Text('Login',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    )),
                Text("Enter the email and password",
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 15,
                    )),
                SizedBox(
                  height: 20,
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
                    errorText: _showEmailError
                        ? 'Please enter a email ex abc@gmail.com'
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  onChanged: _validatePassword,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.greenAccent,
                    ),
                    errorText: _isPasswordValid
                        ? null
                        : 'Password contains one - uppercase,lowercase,one digit, and one special character',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.green,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PasswordResetScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .greenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
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
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text('Dont have an Account ?    SIGNUP ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.green,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
