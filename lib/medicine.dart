import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ntasks/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicineTracker extends StatefulWidget {
  @override
  _MedicineTrackerState createState() => _MedicineTrackerState();
}

class _MedicineTrackerState extends State<MedicineTracker> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _records = [];
  List<String> _selectedTimes = [];
  List<String> _selectedDays = [];

  final List<String> _timeOptions = ['Morning', 'Afternoon', 'Evening', 'Night'];
  final List<String> _dayOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
    'Everyday'
  ];

  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('medicineData');
    if (data != null) {
      final loadedData = jsonDecode(data);
      setState(() {
        _records = List<Map<String, dynamic>>.from(loadedData);
      });
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('medicineData', jsonEncode(_records));
  }

  void _addOrUpdateMedicine(String name, double quantity, List<String> times, List<String> days) {
    final record = {
      'name': name,
      'quantity': quantity,
      'times': List.from(times),
      'days': List.from(days),
      'date': DateTime.now().toIso8601String(),
    };

    setState(() {
      if (_editingIndex != null) {
        _records[_editingIndex!] = record;
        _editingIndex = null;
      } else {
        _records.add(record);
      }
    });

    _clearInputs();
    _saveData();
  }

  void _deleteRecord(int index) {
    setState(() {
      _records.removeAt(index);
    });
    _saveData();
  }

  void _editRecord(int index) {
    final record = _records[index];
    setState(() {
      _editingIndex = index;
      _nameController.text = record['name'];
      _quantityController.text = record['quantity'].toString();
      _selectedTimes = List<String>.from(record['times'] ?? []);
      _selectedDays = List<String>.from(record['days'] ?? []);
    });
  }

  void _clearInputs() {
    _nameController.clear();
    _quantityController.clear();
    _selectedTimes = [];
    _selectedDays = [];
  }

  bool _isSelected(List<String> list, String value) => list.contains(value);

  void _toggleSelection(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        if (value == 'Everyday') {
          list.clear();
        }
        list.add(value);
      }
    });
  }

  InputDecoration _inputDecoration(String label, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final filteredRecords = _records.where((record) {
      final name = record['name'].toString().toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Tracker', style: TextStyle(fontFamily: 'Cardo')),
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
            child: Image.asset(
              'assets/images/hi.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.teal.shade50),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Medicine',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Medicine Name', context),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Quantity', context),
                ),
                SizedBox(height: 10),
                Text('Select Time(s):', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 10,
                  children: _timeOptions.map((time) {
                    final isSelected = _isSelected(_selectedTimes, time);
                    return ChoiceChip(
                      label: Text(time),
                      selected: isSelected,
                      onSelected: (_) => _toggleSelection(_selectedTimes, time),
                      selectedColor: Colors.purple.shade100,
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                Text('Select Days:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 10,
                  children: _dayOptions.map((day) {
                    final isSelected = _isSelected(_selectedDays, day);
                    return ChoiceChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (_) => _toggleSelection(_selectedDays, day),
                      selectedColor: Colors.teal.shade100,
                    );
                  }).toList(),
                ),
                SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final quantity = double.tryParse(_quantityController.text.trim());

                      if (name.isNotEmpty && quantity != null) {
                        _addOrUpdateMedicine(name, quantity, _selectedTimes, _selectedDays);
                      }
                    },
                    child: Text(_editingIndex == null ? 'Add Medicine' : 'Update Medicine',
                        style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      final timeText = (record['times'] as List<dynamic>?)?.join(', ') ?? '';
                      final dayText = (record['days'] as List<dynamic>?)?.join(', ') ?? '';
                      return Card(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.white70,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(
                            '${record['name']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Quantity: ${record['quantity']}\nTime: $timeText\nDays: $dayText\nDate: ${record['date'].toString().substring(0, 16)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: isDarkMode ? Colors.blueAccent : Colors.blue),
                                onPressed: () => _editRecord(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: isDarkMode ? Colors.redAccent : Colors.red),
                                onPressed: () => _deleteRecord(index),
                              ),
                            ],
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
