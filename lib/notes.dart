import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notesJson = prefs.getString('notes');
    if (notesJson != null) {
      List decoded = jsonDecode(notesJson);
      setState(() {
        _notes = List<Map<String, dynamic>>.from(decoded);
        _filteredNotes = List<Map<String, dynamic>>.from(decoded);
      });
    }
  }

  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notes', jsonEncode(_notes));
  }

  void _addNote(String note) {
    if (note.trim().isEmpty) return;
    setState(() {
      _notes.add({"text": note.trim()});
      _filteredNotes.add({"text": note.trim()});
      _noteController.clear();
    });
    _saveNotes();
  }
  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteNote(index);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(int index) {
    final noteToDelete = _filteredNotes[index];
    setState(() {
      _notes.removeWhere((note) => note['text'] == noteToDelete['text']);
      _filteredNotes.removeAt(index);
    });
    _saveNotes();
  }


  void _searchNotes(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredNotes = List.from(_notes);
      } else {
        _filteredNotes = _notes
            .where((note) => note["text"].toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes", style: TextStyle(fontFamily: 'Cardo')),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _noteController,
                  style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Add a note',
                    labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _addNote(_noteController.text);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text('Add', style: TextStyle(color: Colors.black, fontSize: 20)),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Search notes',
                    labelStyle: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (text) {
                    _searchNotes(text);
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Text(_filteredNotes[index]["text"], style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteDialog(context, index);
                            },
                          ),
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
    );
  }
}
