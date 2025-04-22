import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'theme_provider.dart';

class TimeTrackerPage extends StatefulWidget {
  @override
  _TimeTrackerPageState createState() => _TimeTrackerPageState();
}

class _TimeTrackerPageState extends State<TimeTrackerPage> {
  late Timer _timer = Timer(Duration.zero, () {});
  late Timer _stopwatchTimer = Timer(Duration.zero, () {}); // Initialize stopwatch timer

  String _taskName = '';
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _sessions = [];

  Duration _remainingTime = Duration();
  Duration _setTime = Duration();
  bool _isTimerRunning = false;
  bool _alertPlayed = false;
  late AudioPlayer _player;

  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  bool _isStopwatchMode = false;
  bool _isStopwatchRunning = false;

  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadAudio();
    _loadSessions();
  }

  Future<void> _deleteSession(int index) async {
    setState(() {
      _sessions.removeAt(index);
    });
    await _saveSessions();
  }

  Future<void> _loadAudio() async {
    await _player.setAsset('assets/audio/beep_timer.mp3');
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime -= Duration(seconds: 1);
        } else {
          if (!_alertPlayed) {
            _alertPlayed = true;
            _playBeepSound();
          }
          _stopTimer();
        }
      });
    });
  }

  void _startTimer() {
    _remainingTime = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
    if (_remainingTime.inSeconds == 0) return;
    _setTime = _remainingTime;
    _alertPlayed = false;
    _isTimerRunning = true;
    _startCountdownTimer();
  }

  void _pauseTimer() {
    _timer.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    if (_timer.isActive) _timer.cancel();
    setState(() {
      _remainingTime = Duration();
      _setTime = Duration();
      _isTimerRunning = false;
      _alertPlayed = false;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    });
  }

  void _stopTimer() {
    if (_timer.isActive) _timer.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _playBeepSound() async {
    await _player.seek(Duration.zero);
    _player.play();
  }

  Future<void> _saveSession() async {
    if (_taskName.isEmpty || _setTime.inSeconds == 0) return;

    final session = {
      'task': _taskName,
      'duration': _setTime.inSeconds,
      'date': DateTime.now().toIso8601String(),
    };

    _sessions.add(session);
    setState(() {
      _taskName = '';
      _nameController.clear();
    });
    _resetTimer();
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
    _player.dispose();
    if (_timer.isActive) _timer.cancel();
    if (_stopwatchTimer.isActive) _stopwatchTimer.cancel();
    super.dispose();
  }

  void _showSetTimerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Timer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Hours'),
                  onChanged: (val) {
                    _hours = int.tryParse(val) ?? 0;
                  },
                ),
                TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Minutes'),
                  onChanged: (val) {
                    _minutes = int.tryParse(val) ?? 0;
                  },
                ),
                TextField(
                  controller: _secondsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Seconds'),
                  onChanged: (val) {
                    _seconds = int.tryParse(val) ?? 0;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _remainingTime = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
                });
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _startStopwatch() {
    _stopwatchTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _remainingTime += Duration(seconds: 1);
      });
    });
    setState(() {
      _isStopwatchRunning = true;
    });
  }

  void _pauseStopwatch() {
    if (_stopwatchTimer.isActive) _stopwatchTimer.cancel();
    setState(() {
      _isStopwatchRunning = false;
    });
  }

  void _resetStopwatch() {
    if (_stopwatchTimer.isActive) _stopwatchTimer.cancel();
    setState(() {
      _remainingTime = Duration();
      _isStopwatchRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/hi.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.teal.shade50),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(themeProvider.isDarkMode ? 0.4 : 0.2),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Task Timer", style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
                      Switch(
                        value: _isStopwatchMode,
                        onChanged: (val) {
                          setState(() {
                            _isStopwatchMode = val;

                            if (val) {
                              // Switching to Stopwatch mode
                              if (_timer.isActive) _timer.cancel();
                              _remainingTime = Duration();
                              _setTime = Duration();
                              _isTimerRunning = false;
                              _alertPlayed = false;
                              _hours = 0;
                              _minutes = 0;
                              _seconds = 0;
                              _hoursController.clear();
                              _minutesController.clear();
                              _secondsController.clear();
                            } else {
                              // Switching to Timer mode
                              if (_stopwatchTimer.isActive) _stopwatchTimer.cancel();
                              _remainingTime = Duration();
                              _isStopwatchRunning = false;
                            }

                            _taskName = '';
                            _nameController.clear();
                          });
                        },
                      ),
                      Text("Stopwatch", style: TextStyle(fontSize: 16, color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
                    ],
                  ),
                  if (!_isStopwatchMode) ...[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: 20),
                      onChanged: (val) => setState(() => _taskName = val),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showSetTimerDialog,
                      child: Text('Set Timer'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _formatDuration(_remainingTime),
                      style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                          child: Text(_isTimerRunning ? 'Pause' : 'Start'),
                        ),
                        ElevatedButton(
                          onPressed: _resetTimer,
                          child: Text('Reset'),
                        ),
                        ElevatedButton(
                          onPressed: _saveSession,
                          child: Text('Save Task'),
                        ),
                      ],
                    ),
                    Divider(),
                    Text("Tracked Sessions", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final duration = Duration(seconds: session['duration']);
                        return Dismissible(
                          key: Key(session['date']), // Unique key for each item
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => _deleteSession(index),
                          child: ListTile(
                            title: Text(session['task']),
                            subtitle: Text(_formatDuration(duration)),
                            trailing: Text(session['date']),
                          ),
                        );
                      },
                    ),
                  ],
                  if (_isStopwatchMode) ...[
                    SizedBox(height: 20),
                    Text(
                      _formatDuration(_remainingTime),
                      style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isStopwatchRunning ? _pauseStopwatch : _startStopwatch,
                          child: Text(_isStopwatchRunning ? 'Pause' : 'Start'),
                        ),
                        ElevatedButton(
                          onPressed: _resetStopwatch,
                          child: Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}