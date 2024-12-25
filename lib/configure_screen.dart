import 'package:flutter/material.dart';
import 'models/dough.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

typedef OnSaveCallback = void Function(List<Dough> newList);

class ConfigureScreen extends StatefulWidget {
  final List<Dough> doughList;
  final OnSaveCallback onSave;

  const ConfigureScreen({super.key, required this.doughList, required this.onSave});

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
    Dough(name: 'Hoagie', speed1Time: 1, speed2Time: 300),
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController speed1Controller = TextEditingController();
  TextEditingController speed2Controller = TextEditingController();

  int? editingIndex; // Track the index of the dough being edited

  @override
  void initState() {
    super.initState();
    loadDoughList(); // Load saved doughs or use the passed list
  }

  // Load dough data from SharedPreferences
  Future<void> loadDoughList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonList = prefs.getString('doughList');

    if (jsonList != null) {
      setState(() {
        doughList = (jsonDecode(jsonList) as List)
            .map((data) => Dough.fromJson(data))
            .toList();
      });
    } else {
      setState(() {
        doughList = widget.doughList; // Use the passed dough list
      });
    }
  }

  // Save dough data to SharedPreferences
  Future<void> saveDoughList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonList = jsonEncode(doughList.map((dough) => dough.toJson()).toList());
    await prefs.setString('doughList', jsonList);
    widget.onSave(doughList); // Notify parent widget of changes
  }

  // Add a new dough or update an existing one
  void addOrUpdateDough() {
    if (nameController.text.isNotEmpty &&
        speed1Controller.text.isNotEmpty &&
        speed2Controller.text.isNotEmpty) {
      setState(() {
        final newDough = Dough(
          name: nameController.text,
          speed1Time: int.parse(speed1Controller.text) * 60, // Convert minutes to seconds
          speed2Time: int.parse(speed2Controller.text) * 60, // Convert minutes to seconds
        );

        if (editingIndex != null) {
          // Update existing dough
          doughList[editingIndex!] = newDough;
        } else {
          // Add new dough
          doughList.add(newDough);
        }

        // Clear the form and reset editing state
        nameController.clear();
        speed1Controller.clear();
        speed2Controller.clear();
        editingIndex = null;
      });

      saveDoughList(); // Save the updated list
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
      editingIndex = index; // Set the index for editing
    });
  }

  // Delete a dough type
  void deleteDough(int index) {
    setState(() {
      doughList.removeAt(index);
    });
    saveDoughList(); // Save the updated list after deletion
  }

  // Reset to default doughs
  void resetToDefault() async {
    setState(() {
      doughList = List.from(defaultDoughs); // Replace with defaults
    });
    await saveDoughList(); // Persist the reset list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Dough Types'),
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
              decoration: const InputDecoration(labelText: 'Speed 1 Time (minutes)'),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: speed2Controller,
              decoration: const InputDecoration(labelText: 'Speed 2 Time (minutes)'),
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(
            onPressed: addOrUpdateDough,
            child: Text(editingIndex == null ? 'Add Dough' : 'Update Dough'),
          ),
          ElevatedButton(
            onPressed: resetToDefault,
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
                          editDough(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteDough(index);
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
