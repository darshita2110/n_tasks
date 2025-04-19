import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class TimeTrackerPage extends StatefulWidget {
  @override
  _TimeTrackerPageState createState() => _TimeTrackerPageState();
}

class _TimeTrackerPageState extends State<TimeTrackerPage> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _taskName = '';
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _sessions = [];
  int _totalElapsedTime = 0;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _loadSessions();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => setState(() {}));
  }

  void _stopTimer() {
    _timer.cancel();
  }

  void _startTracking() {
    setState(() {
      _stopwatch.start();
      _startTimer();
    });
  }

  void _pauseTracking() {
    setState(() {
      _totalElapsedTime += _stopwatch.elapsed.inSeconds;
      _stopwatch.stop();
      _stopTimer();
    });
  }

  void _resetTracking() {
    setState(() {
      _stopwatch.reset();
      _stopTimer();
      _totalElapsedTime = 0;
      _taskName = '';
    });
  }

  Future<void> _saveSession() async {
    if (_taskName.isEmpty || (_stopwatch.elapsed.inSeconds + _totalElapsedTime) == 0) return;

    final session = {
      'task': _taskName,
      'duration': _stopwatch.elapsed.inSeconds + _totalElapsedTime,
      'date': DateTime.now().toIso8601String(),
    };

    _sessions.add(session);
    setState(() {
      _taskName = '';
      _nameController.clear();
    });
    _resetTracking();
    await _saveSessions();
  }

  Future<void> _saveSessions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('time_sessions', jsonEncode(_sessions));
  }

  Future<void> _loadSessions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('time_sessions');
    if (saved != null) {
      setState(() {
        _sessions = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isRunning = _stopwatch.isRunning;
    final elapsed = _stopwatch.elapsed;

    return Scaffold(
      appBar: AppBar(
        title: Text("Time Tracker", style: TextStyle(fontFamily: 'Cardo', fontWeight: FontWeight.w700)),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      labelStyle: TextStyle(fontSize: 18, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    style: TextStyle(fontSize: 20, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                    onChanged: (val) => setState(() => _taskName = val),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      _formatDuration(elapsed),
                      style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isRunning ? _pauseTracking : _startTracking,
                        child: Text(isRunning ? 'Pause' : 'Start', style: TextStyle(fontSize: 16)),
                      ),
                      ElevatedButton(
                        onPressed: _resetTracking,
                        child: Text('Reset', style: TextStyle(fontSize: 16)),
                      ),
                      ElevatedButton(
                        onPressed: _saveSession,
                        child: Text('Save Task', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  Text("Tracked Sessions", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
                  SizedBox(height: 10),
                  Expanded(
                    child: _sessions.isEmpty
                        ? Center(child: Text("No sessions yet.", style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode ? Colors.white : Colors.black)))
                        : ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[_sessions.length - 1 - index];
                        final duration = Duration(seconds: session['duration']);
                        final date = DateTime.parse(session['date']);
                        return Dismissible(
                          key: Key(session['task']),
                          onDismissed: (direction) {
                            setState(() {
                              _sessions.removeAt(_sessions.length - 1 - index);
                              _saveSessions();
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode ? (Colors.grey[800]?.withOpacity(0.5) ?? Colors.black.withOpacity(0.5)) : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              title: Text(session['task'], style: TextStyle(fontSize: 18, color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
                              subtitle: Text(
                                '${_formatDuration(duration)} • ${date.day}/${date.month}/${date.year}',
                                style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _sessions.removeAt(_sessions.length - 1 - index);
                                    _saveSessions();
                                  });
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
