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
  bool isDarkMode = false; // Track dark mode state

  @override
  void initState() {
    super.initState();
    loadEventsFromLocalStorage(); // Load events when calendar screen opens
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
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      isScrollControlled: true,
      builder: (context) => AddEvent(selectedDate: _selectedDay),
    );
    setState(() {}); // Refresh to show new event
  }

  // Toggle the dark mode
  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Color.fromRGBO(77, 85, 122, 0.8352941176470589)
            : Color.fromRGBO(115, 182, 237, 1.0),
        centerTitle: true,
        title: Text(
          'CALENDAR',
          style: TextStyle(
            fontSize: 35,
            fontFamily: 'Cookie',
            color: isDarkMode ? Colors.white : Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleDarkMode,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(isDarkMode
                ? 'assets/images/dark.jpg' // Change to dark mode background image
                : 'assets/images/calendar.jpg'), // Original background for light mode
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 5, left: 5, bottom: 3),
              child: DropdownButton<CalendarFormat>(
                value: _calendarFormat,
                items: [
                  DropdownMenuItem(
                    value: CalendarFormat.month,
                    child: Text(
                      'Month View',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: CalendarFormat.twoWeeks,
                    child: Text(
                      '2 Weeks View',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: CalendarFormat.week,
                    child: Text(
                      'Week View',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _calendarFormat = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5, bottom: 5),
                child: SingleChildScrollView(
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
                          defaultTextStyle: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Cookie',
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: 22,
                            color: Colors.red.shade700,
                            fontFamily: 'Cookie',
                          ),
                          todayTextStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cookie',
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color.fromRGBO(97, 190, 248, 0.76),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Color.fromRGBO(17, 79, 237, 0.62),
                            shape: BoxShape.circle,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        rowHeight: 70,
                        daysOfWeekHeight: 50,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleTextStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          leftChevronIcon: Icon(Icons.chevron_left, color: isDarkMode ? Colors.white : Colors.black),
                          rightChevronIcon: Icon(Icons.chevron_right, color: isDarkMode ? Colors.white : Colors.black),
                        ),
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
                                      margin: EdgeInsets.symmetric(horizontal: 0.5),
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
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_selectedDay != null &&
                          _listofEventDays(_selectedDay!).isNotEmpty)
                        ..._listofEventDays(_selectedDay!).map((event) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Color.fromRGBO(33, 33, 33, 0.7)
                                  : Color.fromRGBO(170, 216, 246, 0.6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.event,
                                  color: Colors.blue),
                              title: Text(
                                event['eventName'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Cardo',
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                event['descName'],
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Color.fromRGBO(87, 84, 84, 1.0),
                                  fontSize: 18,
                                  fontFamily: 'Cardo',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  setState(() {
                                    String dateString =
                                        '${_selectedDay!.day.toString().padLeft(2, '0')}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.year}';
                                    myEvents[dateString]?.remove(event);
                                    if (myEvents[dateString]?.isEmpty ??
                                        false) {
                                      myEvents.remove(dateString);
                                    }
                                  });

                                  // Save updated events after deletion
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'events', json.encode(myEvents));
                                },
                              ),
                            ),
                          ),
                        )),
                      if (_selectedDay != null &&
                          _listofEventDays(_selectedDay!).isEmpty)
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Color.fromRGBO(33, 33, 33, 0.7)
                                : Color.fromRGBO(192, 225, 246, 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'No events on this day.',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Cardo',
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDarkMode
            ? Color.fromRGBO(132, 197, 243, 0.67)
            : Color.fromRGBO(90, 172, 239, 0.5),
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
      ),
    );
  }
}
