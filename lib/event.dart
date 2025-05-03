import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ntasks/main.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key, required this.selectedDate});
  final DateTime? selectedDate;

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String errorText = '';

  Future<void> saveEventsToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('events', json.encode(myEvents));
  }

  @override

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Add Event',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Cookie',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Event Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter event name',
                filled: true,
                fillColor: Colors.grey[200],
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 15),
            Text('Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter description',
                filled: true,
                fillColor: Colors.grey[200],
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    errorText,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty ||
                      _descController.text.isEmpty) {
                    setState(() {
                      errorText = 'Event name and description are required!';
                    });
                    return;
                  } else {
                    String name = _nameController.text;
                    String desc = _descController.text;

                    print("Event: $name\nDescription: $desc");

                    String dateString = (widget.selectedDate != null)
                        ? DateFormat('dd-MM-yyyy')
                        .format(widget.selectedDate!)
                        .toString()
                        : DateFormat('dd-MM-yyyy')
                        .format(DateTime.now())
                        .toString();

                    if (myEvents[dateString] != null) {
                      myEvents[dateString]?.add({
                        "eventName": _nameController.text,
                        "descName": _descController.text
                      });
                    } else {
                      myEvents[dateString] = [
                        {
                          "eventName": _nameController.text,
                          "descName": _descController.text
                        }
                      ];
                    }

                    await saveEventsToLocalStorage(); // Save events to local storage
                    final flutterLocalNotificationsPlugin =
                    Provider.of<FlutterLocalNotificationsPlugin>(context, listen: false);
                    var android = AndroidNotificationDetails(
                        'channel id', 'channel NAME',
                        priority: Priority.high, importance: Importance.max);
                    var platform = NotificationDetails(android: android);
                    flutterLocalNotificationsPlugin.show(
                        0, 'Event Added!👍', 'Event "${_nameController.text.trim()}" saved!', platform,
                        payload: 'Event saved');

                    print(
                        "New event added: ${json.encode(myEvents)}");

                    saveEventsToLocalStorage().then((_) {
                      Navigator.pop(context);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Color.fromRGBO(60, 160, 204, 0.68),
                  padding:
                  EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Cookie',
                      color: Colors.white),
                ),
              ),


            )
          ],
        ),
      ),
    );
  }
}
