// calendar.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

Map<String, List> myEvents = {};

List _listofEventDays(DateTime dateTime) {
  String dateString =
      '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
  return myEvents[dateString] ?? [];
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    loadEventsFromLocalStorage(); // 👈 Load events when calendar screen opens
  }

  Future<void> loadEventsFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEvents = prefs.getString('events');
    if (storedEvents != null) {
      setState(() {
        myEvents = Map<String, List>.from(json.decode(storedEvents));
      });
    }
  }


  showAddEventBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => AddEvent(selectedDate: _selectedDay),
    );
    setState(() {}); // Refresh to show new event
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(90, 172, 239, 0.5),
        centerTitle: true,
        title: const Text(
          'CALENDAR',
          style: TextStyle(
              fontSize: 35,
              fontFamily: 'Cookie',
              color: Color.fromRGBO(0, 0, 0, 1)),
        ),
      ), // AppBar
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/calendar.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:5.0, right: 5,left: 5,bottom: 3),
              child: DropdownButton<CalendarFormat>(
                value: _calendarFormat,
                items: const [
                  DropdownMenuItem(
                    value: CalendarFormat.month,
                    child: Text('Month View'),
                  ),
                  DropdownMenuItem(
                    value: CalendarFormat.twoWeeks,
                    child: Text('2 Weeks View'),
                  ),
                  DropdownMenuItem(
                    value: CalendarFormat.week,
                    child: Text('Week View'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _calendarFormat = value!;
                  });
                },
              ),
            ), // Dropdown
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left:5.0, right: 5, bottom:5,),
                child: 
                SingleChildScrollView(
                  child: Column(
                    children: [
                      TableCalendar(
                        focusedDay: _focusedDay,
                        firstDay: DateTime(1947),
                        lastDay: DateTime(2035),
                        calendarFormat: _calendarFormat,
                        calendarStyle: CalendarStyle(
                          cellMargin: EdgeInsets.zero,
                          isTodayHighlighted: true,
                          defaultTextStyle:
                          TextStyle(fontSize: 22, fontFamily: 'Cookie'),
                          weekendTextStyle: TextStyle(
                              fontSize: 22,
                              color: Colors.red.shade700,
                              fontFamily: 'Cookie'),
                          todayTextStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cookie'),
                          weekNumberTextStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cookie'),
                          todayDecoration: BoxDecoration(
                              color: Color.fromRGBO(97, 190, 248, 0.76),
                              shape: BoxShape.circle),
                          selectedDecoration: BoxDecoration(
                            color: Color.fromRGBO(17, 79, 237, 0.62),
                            shape: BoxShape.circle,
                          ),
                        ), // CalendarStyle
                        daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            weekendStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700)),
                        rowHeight: 70,
                        daysOfWeekHeight: 50,
                        headerStyle: HeaderStyle(formatButtonVisible: false),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        eventLoader: _listofEventDays,
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isNotEmpty) {
                              return Positioned(
                                bottom: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(events.length, (index) {
                                    return Container(
                                      margin:
                                      EdgeInsets.symmetric(horizontal: 0.5),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromRGBO(250, 50, 50, 1.0),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        ), // CalendarBuilders
                      ), // TableCalendar
                      const SizedBox(height: 10),
                      if (_selectedDay != null &&
                          _listofEventDays(_selectedDay!).isNotEmpty)
                        ..._listofEventDays(_selectedDay!).map((event) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(color: Color.fromRGBO(
                                170, 216, 246, 0.6), borderRadius: BorderRadius.circular(30)) ,
                            child: ListTile(
                              leading: const Icon(Icons.event, color: Colors.blue),
                              title: Text(event['eventName'],
                                  style: const TextStyle(fontSize: 20, fontFamily: 'Cardo', fontWeight: FontWeight.w600)),
                              subtitle: Text(event['descName'],
                                  style: TextStyle(color: Color.fromRGBO(87, 84, 84, 1.0), fontSize: 18, fontFamily: 'Cardo', fontWeight: FontWeight.w600)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  setState(() {
                                    String dateString = '${_selectedDay!.day.toString().padLeft(2, '0')}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.year}';
                                    myEvents[dateString]?.remove(event);
                                    if (myEvents[dateString]?.isEmpty ?? false) {
                                      myEvents.remove(dateString);
                                    }
                                  });

                                  // Save updated events after deletion
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('events', json.encode(myEvents));
                                },
                              ),
                            )

                          ),
                        )),
                      if (_selectedDay != null &&
                          _listofEventDays(_selectedDay!).isEmpty)
                        Container( padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(color: Color.fromRGBO(
                              192, 225, 246, 0.792156862745098), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            'No events on this day.',
                            style:
                            TextStyle(fontSize: 18, fontFamily: 'Cardo' , fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ), // Column inside Expanded
              ),
            ), // Expanded
          ],
        ), // Column
      ), // Container
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromRGBO(132, 197, 243, 0.67),
        onPressed: () {
          showAddEventBottomSheet();
        },
        label: const Text(
          ' Add Event :',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Cookie',
          ),
        ),
      ), // FAB
    ); // Scaffold
  } // build
} // _CalendarState
