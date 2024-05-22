
import 'package:evehicle/second.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'First Screen',
        theme: ThemeData(),
        home: MyHomePage(),
        routes: <String, WidgetBuilder>{
          '/screen1': (BuildContext context) => MyApp(),
          '/screen2': (BuildContext context) => Second(),
          //'/screen3': (BuildContext context) => (),
          // '/screen4': (BuildContext context) => grid(),
          // '/screen5': (BuildContext context) => LoginPage(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _newpage() {
    Navigator.pushNamed(
        context, '/screen2'); // Navigate to the next screen (SecondRoute)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          GestureDetector(
            onTap: _newpage,
            child: Container(
              child: Image.asset(
                "assets/logo.png",
                width: 500,
                height: 600,
              ),
            ),
          ),
          Container(
            child: Text("E-Vehicle Recharge",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }
}
