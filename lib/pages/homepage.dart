import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? username = (FirebaseAuth.instance.currentUser?.email.toString() != "")
      ? FirebaseAuth.instance.currentUser?.email
      : 'No User found';
  String? userUID = (FirebaseAuth.instance.currentUser!.uid != "")
      ? FirebaseAuth.instance.currentUser?.uid
      : 'No User found';

  TextEditingController taskController = TextEditingController();

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String task = '';

  List<Map<String, dynamic>> tasklist = [];
  @override
  void initState() {
    super.initState();
    getDataFromFirestore();
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Logged out successfull..!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        )));
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    // Initialize a list to hold the Text widgets
    List<Widget> taskWidgets = [];

    // Use a for loop to build the list of widgets
    for (var task in tasklist) {
      taskWidgets.add(
        Text(
          task['task_name'] ?? 'No Task Name', // Safely access 'task_name'
          style: TextStyle(fontSize: 18), // Optional: style for the text
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Task Manager',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
              onPressed: () {
                logout();
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [Text('workin')], // Use the list of Text widgets
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var temp = await openDialog();
          if (temp == null && temp!.isEmpty) return;
          setState(() {
            task = temp;
          });
          addTask();
        },
        backgroundColor: Colors.indigo[400],
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<String?> openDialog() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Enter TODO task'),
            content: TextField(
              onSubmitted: (_) => submit,
              controller: taskController,
              autofocus: true,
              decoration: InputDecoration(
                label: Text('Task...'),
              ),
            ),
            actions: [
              TextButton(onPressed: submit, child: Text('Add Task')),
            ],
          ));
  void submit() {
    Navigator.of(context).pop(taskController.text);
    taskController.clear();
  }

  void addTask() async {
    try {
      await _firebaseFirestore
          .collection('tasks')
          .add({'task_name': task, 'user_UID': userUID, 'is_Completed': false});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          backgroundColor: Colors.green,
          content: Text(
            'Task Added..!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> getDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await _firebaseFirestore.collection('tasks').get();

      tasklist = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      log(e.toString());
    }
  }
}
