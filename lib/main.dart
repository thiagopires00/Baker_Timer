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
  final List<Dough> defaultDoughs = [
    Dough(name: 'Sando/country/tin bread', speed1Time: 300, speed2Time: 300),
    Dough(name: 'Miche', speed1Time: 480, speed2Time: 60),
    Dough(name: 'Wholewheat', speed1Time: 600, speed2Time: 60),
    Dough(name: 'Bagel', speed1Time: 300, speed2Time: 300),
    Dough(name: 'Baguette', speed1Time: 180, speed2Time: 180),
    Dough(name: 'Italian rustic', speed1Time: 300, speed2Time: 600),
    Dough(name: 'Burger bun and Brioche', speed1Time: 300, speed2Time: 600),
    Dough(name: 'Croissant and cinnamon scrolls', speed1Time: 300, speed2Time: 480),
    Dough(name: '100 % rye', speed1Time: 300, speed2Time: 360),
    Dough(name: 'Hoagie', speed1Time: 600, speed2Time: 300),
  ];

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
      title: 'Bakers Timer', // Updated app title
      debugShowCheckedModeBanner: false, // Hide the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder( // Use Builder to create a new context for Navigator
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bakers Timer'),
            ),
            body: Center(
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
          );
        },
      ),
    );
  }
}
