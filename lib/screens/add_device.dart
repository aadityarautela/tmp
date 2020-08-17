import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tank_app/screens/home.dart';

class AddDeviceRoute extends StatefulWidget {
  @override
  _AddDeviceRouteState createState() => _AddDeviceRouteState();
}

class _AddDeviceRouteState extends State<AddDeviceRoute> {
  final _formKey = GlobalKey<FormState>();

  final firestoreInstance = Firestore.instance;

  final textController = TextEditingController();

  String idToCheck;

  bool idExists = false;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new device'),
      ),
      body: Center(
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid ID';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  controller: textController,
                ),
              ],
            )),
      ),
      floatingActionButton: FlatButton.icon(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          if (_formKey.currentState.validate()) {
            idToCheck = textController.text;
            firestoreInstance
                .collection('devices')
                .document(idToCheck)
                .get()
                .then((value) {
              if (!value.exists) {
                idExists = false;
              } else {
                idExists = true;
              }

              if (idExists) {
                List<String> devices = prefs.getStringList('devices') ?? [];
                if (devices.contains(idToCheck)) {
                  devices.add(idToCheck);
                  prefs.setStringList("devices", devices);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Device already added'),
                          content: Text('You have already added that device'),
                          actions: [
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'))
                          ],
                        );
                      });
                }
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Device not found'),
                        content: Text('Check the device id entered'),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'))
                        ],
                      );
                    });
              }
            });
          }
        },
        icon: Icon(Icons.add),
        label: Text('Add'),
      ),
    );
  }
}
