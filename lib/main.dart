import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_app_flutter/pages/homepage.dart';
import 'package:todo_app_flutter/pages/login.dart';
import 'package:todo_app_flutter/pages/signup.dart';
import 'package:todo_app_flutter/theme/theme_data.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  return runApp(MaterialApp(
    theme: lightTheme,
    initialRoute: (FirebaseAuth.instance.currentUser != null) ? '/home' : '/',
    routes: {
      '/': (context) => const Login(),
      '/signup': (context) => const Signup(),
      '/home': (context) => const Home(),
    },
  ));
}
