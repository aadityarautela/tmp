import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tank_app/classes/device.dart';
import 'package:tank_app/screens/add_device.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firestoreInstance = Firestore.instance;
  List dev;
  List<WaterData> devices = [];

  void _getInit() async {
    final prefs = await SharedPreferences.getInstance();

    dev = prefs.getStringList("devices") ?? [];

    dev.forEach((element) {
      WaterData d = new WaterData(element);

      firestoreInstance
          .collection("devices")
          .document(element)
          .snapshots()
          .listen((value) {
        var waterLevel = value.data["waterLevel"];
        var tankDepth = value.data["tankDepth"];
        var waterLevelPercentage = waterLevel / tankDepth;
        d.getData(waterLevel, waterLevelPercentage);

        setState(() {
          devices.add(d);
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Level'),
        leading: Container(),
      ),
      body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: CircularProgressIndicator(
                  backgroundColor: Colors.indigo[50],
                  value: devices[index].waterLevelPercentage,
                  strokeWidth: 8,
                ),
                title: Text(
                    "Current Water Level is ${(devices[index].waterLevelPercentage * 100).round().toString()}%"),
                subtitle: Text((() {
                  if (devices[index].waterLevelPercentage > 0.2) {
                    return "Status OK";
                  } else {
                    return "Status Low";
                  }
                })()),
                trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        devices.removeAt(index);
                        dev.removeAt(index);
                      });
                    }),
              ),
            );
          }),
      floatingActionButton: FlatButton.icon(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddDeviceRoute()));
        },
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          'Add a new device',
          style: TextStyle(color: Colors.white),
        ),
        color: Colors.pinkAccent,
      ),
    );
  }
}
