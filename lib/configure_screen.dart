import 'package:flutter/material.dart';
import 'models/dough.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

typedef OnSaveCallback = void Function(List<Dough> newList);

class ConfigureScreen extends StatefulWidget {
  final List<Dough> doughList;
  final OnSaveCallback onSave;

  ConfigureScreen({required this.doughList, required this.onSave});

  @override
  _ConfigureScreenState createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
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
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController speed1Controller = TextEditingController();
  TextEditingController speed2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    doughList = widget.doughList; // Initialize with the passed dough list
  }

  // Save dough data to SharedPreferences
  Future<void> _saveDoughList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonList = jsonEncode(doughList.map((dough) => dough.toJson()).toList());
    await prefs.setString('doughList', jsonList);
    print('Dough List Saved: $jsonList'); // Debugging line
  }

  // Add a new dough or update existing
  void addOrUpdateDough({int? index}) {
    if (nameController.text.isNotEmpty && speed1Controller.text.isNotEmpty && speed2Controller.text.isNotEmpty) {
      setState(() {
        final newDough = Dough(
          name: nameController.text,
          speed1Time: int.parse(speed1Controller.text) * 60, // Convert minutes to seconds
          speed2Time: int.parse(speed2Controller.text) * 60, // Convert minutes to seconds
        );

        if (index != null) {
          // Update existing dough
          doughList[index] = newDough;
        } else {
          // Add new dough
          doughList.add(newDough);
        }

        nameController.clear();
        speed1Controller.clear();
        speed2Controller.clear();
      });

      _saveDoughList(); // Save the updated list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  // Edit a dough type
  void editDough(int index) {
    setState(() {
      nameController.text = doughList[index].name;
      speed1Controller.text = (doughList[index].speed1Time ~/ 60).toString(); // Convert seconds to minutes
      speed2Controller.text = (doughList[index].speed2Time ~/ 60).toString(); // Convert seconds to minutes
    });
  }

  // Delete a dough type
  void deleteDough(int index) {
    setState(() {
      doughList.removeAt(index);
    });
    _saveDoughList(); // Save the updated list after deletion
  }

  // Reset to default doughs
  void resetToDefault() {
    setState(() {
      doughList = List.from(defaultDoughs);
    });
    _saveDoughList(); // Save the reset list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Dough Types'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(doughList); // Pass the dough list back to the parent
              Navigator.pop(context); // Close the screen
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Dough Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: speed1Controller,
              decoration: const InputDecoration(labelText: 'Speed 1 Time (minutes)'), // Updated label to minutes
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: speed2Controller,
              decoration: const InputDecoration(labelText: 'Speed 2 Time (minutes)'), // Updated label to minutes
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(
            onPressed: () => addOrUpdateDough(), // Add new dough
            child: const Text('Add Dough'),
          ),
          ElevatedButton(
            onPressed: () => resetToDefault(), // Reset to default doughs
            child: const Text('Reset to Default'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: doughList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(doughList[index].name),
                  subtitle: Text(
                    'Speed 1: ${doughList[index].speed1Time ~/ 60} min, Speed 2: ${doughList[index].speed2Time ~/ 60} min',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          editDough(index); // Edit existing dough
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteDough(index); // Delete dough
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
