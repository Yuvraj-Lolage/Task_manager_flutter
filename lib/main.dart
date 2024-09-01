import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_basics/pages/homepage.dart';
import 'package:flutter_firebase_basics/pages/login.dart';
import 'package:flutter_firebase_basics/pages/signup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  return runApp(MaterialApp(
    initialRoute: (FirebaseAuth.instance.currentUser != null) ? '/home' : '/',
    routes: {
      '/': (context) => const Login(),
      '/signup': (context) => const Signup(),
      '/home': (context) => const Home(),
    },
  ));
}
