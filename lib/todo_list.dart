import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import './checkbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ToDoList extends StatefulWidget {
  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('todo_tasks');
    if (tasksJson != null) {
      List decoded = jsonDecode(tasksJson);
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(decoded);
      });
    }
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('todo_tasks', jsonEncode(_tasks));
  }

  void _addTask(String task) {
    if (task.trim().isEmpty) return;
    setState(() {
      _tasks.add({"text": task.trim(), "isChecked": false});
      _taskController.clear();
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _toggleCheckbox(int index, bool? value) {
    setState(() {
      _tasks[index]["isChecked"] = value;
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List", style: TextStyle(fontFamily: 'Cardo')),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image(
              image: AssetImage('assets/images/hi.jpg'),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.teal.shade50);
              },
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(themeProvider.isDarkMode ? 0.4 : 0.2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                const Text(
                  "  Your TODO List : ",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cardo',
                    color: Color.fromRGBO(235, 236, 235, 0.96),
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 5,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(_tasks[index]["text"]),
                        onDismissed: (direction) {
                          _deleteTask(index);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ToDoItem(
                          text: _tasks[index]["text"],
                          isChecked: _tasks[index]["isChecked"],
                          onChanged: (val) => _toggleCheckbox(index, val),
                          onDelete: () => _deleteTask(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _taskController,
                cursorColor: Color.fromRGBO(145, 77, 40, 1.0),
                style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Add a new task",
                  hintStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: themeProvider.isDarkMode ? Colors.white : Color.fromRGBO(0, 0, 139, 1.0),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: themeProvider.isDarkMode
                      ? Color.fromRGBO(66, 66, 66, 1.0) // Dark mode text field background
                      : Color.fromRGBO(173, 216, 230, 1.0), // Light mode text field background
                  prefixIcon: Icon(Icons.add, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _addTask(_taskController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Add",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cookie',
                  color: Colors.black, // White text for the button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
