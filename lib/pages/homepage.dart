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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firebaseFirestore
                        .collection('tasks')
                        .where('user_UID', isEqualTo: userUID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> taskData =
                                  snapshot.data?.docs[index].data()
                                      as Map<String, dynamic>;
                              DocumentSnapshot document =
                                  snapshot.data!.docs[index];

                              return Column(
                                children: [
                                  CheckboxListTile(
                                      title: Text(
                                        taskData['task_name'],
                                        style: TextStyle(
                                            decoration:
                                                (taskData['is_Completed'])
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none),
                                      ),
                                      activeColor: Colors.green[600],
                                      tileColor: (taskData['is_Completed'])
                                          ? Colors.green[100]
                                          : Colors.grey[50],
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: (taskData['is_Completed'])
                                          ? true
                                          : false,
                                      onChanged: (bool? value) {
                                        if (value != null) {
                                          // Update Firestore with new value
                                          _firebaseFirestore
                                              .collection('tasks')
                                              .doc(document.id)
                                              .update({
                                            'is_Completed': value
                                          }).catchError((error) {
                                            // Handle errors
                                            print(
                                                "Error updating document: $error");
                                          });
                                        }
                                      },
                                      secondary: IconButton(
                                          onPressed: () {
                                            deleteTask(document.id);
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ))),
                                  const Divider(height: 0),
                                ],
                              );
                            },
                          );
                        } else {
                          return Text('Error Displaing Data');
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              )
            ], // Use the list of Text widgets
          ),
        ),
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

  void deleteTask(String id) async {
    try {
      await _firebaseFirestore.collection('tasks').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          backgroundColor: Colors.green,
          content: Text(
            'Task Deleted..!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));
    } catch (e) {
      log(e.toString());
    }
  }
}
