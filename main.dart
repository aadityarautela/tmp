import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(WaterLevel(newID: 'NULL'));
}

class WaterLevel extends StatelessWidget {
  final String newID;
  WaterLevel({Key key, @required this.newID}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.indigo,
      ),
      //home: HomeScreen(newID: newID),
      home: HomeScreen(newID: newID),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String newID;
  HomeScreen({Key key, @required this.newID}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState(newID);
}

class _HomeScreenState extends State<HomeScreen> {
  String newID = "";
  final firestoreInstance = Firestore.instance;
  //List<String> devices = ['w3uvYR7xk4hzF6iKTRXz'];
  List<waterData> devices = [
    waterData('w3uvYR7xk4hzF6iKTRXz'),
    waterData('M0IDKVCfxmB1KWGrfH2f')
  ];
  int waterLevel = 0;
  int tankDepth = 1;
  double waterLevelPercentage;

  _HomeScreenState(this.newID) {
    print(newID);
  }

  void _getInit() async {
    devices.asMap().forEach((index, element) {
      firestoreInstance
          .collection("devices")
          .document(element.id)
          .snapshots()
          .listen((value) {
        setState(() {
          waterLevel = value.data["waterLevel"];
          tankDepth = value.data["tankDepth"];
          waterLevelPercentage = waterLevel / tankDepth;
          devices[index].getData(waterLevel, waterLevelPercentage);
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (newID != 'NULL') {
      devices.add(waterData(newID));
    }
    newID = 'NULL';
    print(this.newID);
    _getInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Level'),
      ),
      body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: CircularProgressIndicator(
                  backgroundColor: Colors.indigo[50],
                  value: devices[index].waterLevelPercentage,
                ),
                title: Text(devices[index].waterLevel.toString()),
              ),
            );
          }),
      floatingActionButton: FlatButton.icon(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddDeviceRoute()));
          },
          icon: Icon(Icons.add),
          label: Text('Add a new device')),
    );
  }
}

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
        onPressed: () {
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WaterLevel(newID: idToCheck)));
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

class waterData {
  String id;
  int waterLevel;
  double waterLevelPercentage;
  waterData(this.id);
  void getData(int wL, double wLP) {
    this.waterLevel = wL;
    this.waterLevelPercentage = wLP;
  }
}
