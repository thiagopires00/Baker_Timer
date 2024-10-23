import 'package:flutter/material.dart';
import 'configure_screen.dart'; // Import ConfigureScreen
import 'timer_screen.dart'; // Import TimerScreen
import 'models/dough.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const DoughTimerApp());
}

class DoughTimerApp extends StatefulWidget {
  const DoughTimerApp({Key? key}) : super(key: key);

  @override
  _DoughTimerAppState createState() => _DoughTimerAppState();
}

class _DoughTimerAppState extends State<DoughTimerApp> {
  List<Dough> doughList = [];

  @override
  void initState() {
    super.initState();
    _loadDoughList(); // Load saved dough types when the app starts
  }

  // Load dough list from SharedPreferences
  Future<void> _loadDoughList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? doughData = prefs.getString('doughList');

    if (doughData != null) {
      List<dynamic> jsonList = jsonDecode(doughData);
      setState(() {
        doughList = jsonList.map((item) => Dough.fromJson(item)).toList();
      });
    }
  }

  // Save dough list to SharedPreferences
  Future<void> _saveDoughList(List<Dough> newList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonList = jsonEncode(newList.map((dough) => dough.toJson()).toList());
    await prefs.setString('doughList', jsonList);
    setState(() {
      doughList = newList; // Update the local list
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dough Timer App'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to ConfigureScreen, and pass the dough list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfigureScreen(
                          doughList: doughList,
                          onSave: (newList) {
                            _saveDoughList(newList); // Save the updated dough list
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Configure Dough Types'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (doughList.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimerScreen(doughList: doughList),
                        ),
                      );
                    } else {
                      // Show a snack bar if no dough is configured
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No dough types configured yet!')),
                      );
                    }
                  },
                  child: const Text('Start Timer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
