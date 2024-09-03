import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailCotroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset password'),
      ),
      body: Column(
        children: [
          TextField(
            controller: emailCotroller,
            decoration: InputDecoration(label: Text('Enter email')),
          ),
          SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                  onPressed: () {
                    forgotPassword();
                  },
                  child: Text('Send mail')))
        ],
      ),
    );
  }

  void forgotPassword() {
    try {
      FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailCotroller.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          backgroundColor: Colors.green,
          content: Text(
            'Email sent for reset password, NOTE: also check spam folder',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      log(e.toString());
    }
  }
}
