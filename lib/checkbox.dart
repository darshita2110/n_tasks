import 'package:flutter/material.dart';
import 'package:ntasks/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ToDoItem extends StatelessWidget {
  final String text;
  final bool? isChecked;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onDelete;

  const ToDoItem({
    super.key,
    required this.text,
    this.isChecked,
    this.onChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 10, bottom: 10, left: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(220, 219, 217, 0.84),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Theme(
              data: ThemeData(
                unselectedWidgetColor: Colors.black,
              ),
              child: Checkbox(
                tristate: true,
                activeColor: Color.fromRGBO(90, 61, 22, 1.0),
                value: isChecked,
                onChanged: (bool? value) {
                  onChanged?.call(value);
                  if (value == true) {
                    final flutterLocalNotificationsPlugin =
                        Provider.of<FlutterLocalNotificationsPlugin>(context, listen: false);
                    var android = AndroidNotificationDetails(
                        'channel id', 'channel NAME',
                        priority: Priority.high, importance: Importance.max);
                    var platform = NotificationDetails(android: android);
                    flutterLocalNotificationsPlugin.show(
                        0, 'Hooray! 🎉', 'Task "${text.trim()}" completed!😄', platform,
                        payload: 'Task completed');
                  }
                },
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Cardo',
                  fontSize: 20,
                  color: Colors.black,
                  decoration: isChecked == true
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete,
                  color: Color.fromRGBO(135, 78, 4, 1.0)),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
