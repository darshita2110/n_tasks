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
  final TextEditingController _typeController = TextEditingController();

  List<Map<String, dynamic>> _records = [];
  double _totalStock = 0.0;

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
        _totalStock = _records.fold(0.0, (sum, item) => sum + item['quantity']);
      });
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('medicineData', jsonEncode(_records));
  }

  void _addMedicine(String name, double quantity, String type) {
    setState(() {
      final record = {
        'name': name,
        'quantity': quantity,
        'type': type,
        'date': DateTime.now().toIso8601String(),
      };
      _records.add(record);
      if (type == 'Added') {
        _totalStock += quantity;
      } else {
        _totalStock -= quantity;
      }
    });
    _saveData();
  }

  void _deleteRecord(int index) {
    setState(() {
      if (_records[index]['type'] == 'Taken') {
        _totalStock += _records[index]['quantity'];
      } else {
        _totalStock -= _records[index]['quantity'];
      }
      _records.removeAt(index);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Container(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Stock: $_totalStock',
                  style: _textStyle(context: context),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Medicine Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Quantity'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _typeController,
                  decoration: _inputDecoration('Type (Added/Taken)'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text;
                    final quantity = double.tryParse(_quantityController.text);
                    final type = _typeController.text;
                    if (name.isNotEmpty && quantity != null && type.isNotEmpty) {
                      _addMedicine(name, quantity, type);
                      _nameController.clear();
                      _quantityController.clear();
                      _typeController.clear();
                    }
                  },
                  child: Text('Add Medicine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        color: Colors.white70,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(
                            '${record['name']}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Quantity: ${record['quantity']} - Type: ${record['type']} - Date: ${record['date']}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRecord(index),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(),
    );
  }

  TextStyle _textStyle({Color? color, required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color ?? (isDark ? Colors.white : Colors.black),
    );
  }
}
