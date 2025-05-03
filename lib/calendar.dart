import 'dart:convert';
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
  bool isDarkMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadEventsFromLocalStorage();
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
    setState(() {});
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Color.fromRGBO(77, 85, 122, 0.835)
            : Color.fromRGBO(115, 182, 237, 1.0),
        centerTitle: true,
        title: Text(
          'CALENDAR',
          style: TextStyle(
            fontSize: 35,
            fontFamily: 'Cookie',
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.brightness_2 : Icons.wb_sunny,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: toggleDarkMode,
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(isDarkMode
                ? 'assets/images/dark.jpg'
                : 'assets/images/calendar.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.only(top: 5.0, right: 5, left: 5, bottom: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<CalendarFormat>(
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
                ],
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
                          leftChevronIcon: Icon(Icons.chevron_left,
                              color:
                              isDarkMode ? Colors.white : Colors.black),
                          rightChevronIcon: Icon(Icons.chevron_right,
                              color:
                              isDarkMode ? Colors.white : Colors.black),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.blue,
              ),
              child: Text(
                'Calendar Options',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text('Go to Date'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => GoToDateDialog(
                    isDarkMode: isDarkMode,
                    onDateSelected: (date) {
                      setState(() {
                        _focusedDay = date;
                      });
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Go to Event'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => GoToEventDialog(
                    isDarkMode: isDarkMode,
                    onEventFound: (date) {
                      setState(() {
                        _focusedDay = date;
                      });
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('See All Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllEventsPage(
                      isDarkMode: isDarkMode,
                      events: myEvents,
                    ),
                  ),
                );
              },

            ),
          ],
        ),
      ),
    );
  }
}

class GoToDateDialog extends StatefulWidget {
  final bool isDarkMode;
  final Function(DateTime) onDateSelected;

  GoToDateDialog({required this.isDarkMode, required this.onDateSelected});

  @override
  _GoToDateDialogState createState() => _GoToDateDialogState();
}

class _GoToDateDialogState extends State<GoToDateDialog> {
  int? selectedDay;
  int? selectedMonth;
  int? selectedYear;

  final List<int> days = List.generate(31, (index) => index + 1);
  final List<int> months = List.generate(12, (index) => index + 1);
  final List<int> years = List.generate(150, (index) => DateTime.now().year - index);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      title: Text(
        'Select Date',
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDropdown('Day', days, selectedDay, (val) {
            setState(() {
              selectedDay = val;
            });
          }),
          buildDropdown('Month', months, selectedMonth, (val) {
            setState(() {
              selectedMonth = val;
            });
          }),
          buildDropdown('Year', years, selectedYear, (val) {
            setState(() {
              selectedYear = val;
            });
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel', style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedDay == null || selectedMonth == null || selectedYear == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select day, month, and year')),
              );
              return;
            }
            try {
              DateTime selectedDate = DateTime(selectedYear!, selectedMonth!, selectedDay!);
              if (selectedDate.day != selectedDay) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Date not valid')),
                );
                return;
              }
              widget.onDateSelected(selectedDate);
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Date not valid')),
              );
            }
          },
          child: Text('Go'),
        ),
      ],
    );
  }

  Widget buildDropdown(String hint, List<int> items, int? selected, Function(int?) onChanged) {
    return DropdownButton<int>(
      hint: Text(hint, style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
      value: selected,
      dropdownColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
      items: items.map((item) {
        return DropdownMenuItem<int>(
          value: item,
          child: Text('$item', style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class GoToEventDialog extends StatefulWidget {
  final bool isDarkMode;
  final Function(DateTime) onEventFound;

  GoToEventDialog({required this.isDarkMode, required this.onEventFound});

  @override
  _GoToEventDialogState createState() => _GoToEventDialogState();
}

class _GoToEventDialogState extends State<GoToEventDialog> {
  TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      title: Text(
        'Enter Event Name',
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: TextField(
        controller: _eventController,
        decoration: InputDecoration(
          hintText: 'Event Name',
          hintStyle: TextStyle(
            color: widget.isDarkMode ? Colors.white54 : Colors.black54,
          ),
        ),
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel',
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
        ),
        ElevatedButton(
          onPressed: () {
            String searchEvent = _eventController.text.trim();
            bool found = false;
            DateTime? foundDate;

            myEvents.forEach((dateStr, eventsList) {
              if (eventsList.any((event) =>
              event.toString().toLowerCase() == searchEvent.toLowerCase())) {
                found = true;
                List<String> parts = dateStr.split('-');
                foundDate = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              }
            });

            if (found && foundDate != null) {
              widget.onEventFound(foundDate!);
              Navigator.pop(context);
            } else {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                  title: Text(
                    'Event Not Found',
                    style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black),
                  ),
                  content: Text(
                    'No such event found.',
                    style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(
                            color:
                            widget.isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text('Go'),
        ),
      ],
    );
  }
}

class AllEventsPage extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, List> events;

  AllEventsPage({required this.isDarkMode, required this.events});

  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  List<MapEntry<String, List>> sortedEvents = [];
  List<bool> selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _sortEvents();
  }

  void _sortEvents() {
    sortedEvents = widget.events.entries.toList()
      ..sort((a, b) {
        List<String> aParts = a.key.split('-');
        List<String> bParts = b.key.split('-');
        DateTime aDate = DateTime(
          int.parse(aParts[2]),
          int.parse(aParts[1]),
          int.parse(aParts[0]),
        );
        DateTime bDate = DateTime(
          int.parse(bParts[2]),
          int.parse(bParts[1]),
          int.parse(bParts[0]),
        );
        return aDate.compareTo(bDate);
      });
    selectedEvents = List.generate(sortedEvents.length, (index) => false);
  }

  void _deleteSelectedEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      for (int i = selectedEvents.length - 1; i >= 0; i--) {
        if (selectedEvents[i]) {
          widget.events.remove(sortedEvents[i].key);
          sortedEvents.removeAt(i);
        }
      }
      selectedEvents = List.generate(sortedEvents.length, (index) => false);
    });

    await prefs.setString('events', json.encode(widget.events));
  }

  void _editEvent(int dateIndex, int eventIndex) async {
    final eventController = TextEditingController(
      text: sortedEvents[dateIndex].value[eventIndex].toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Edit Event',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: TextField(
          controller: eventController,
          decoration: InputDecoration(
            hintText: 'Event Name',
            hintStyle: TextStyle(
              color: widget.isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (eventController.text.trim().isEmpty) return;

              SharedPreferences prefs = await SharedPreferences.getInstance();
              setState(() {
                sortedEvents[dateIndex].value[eventIndex] = eventController.text.trim();
                widget.events[sortedEvents[dateIndex].key] = sortedEvents[dateIndex].value;
              });

              await prefs.setString('events', json.encode(widget.events));
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.blue,
        title: Text(
          'All Events',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
        ),
        iconTheme: IconThemeData(color: widget.isDarkMode ? Colors.white : Colors.black),
        actions: [
          if (selectedEvents.any((isSelected) => isSelected))
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedEvents,
              tooltip: 'Delete selected',
            ),
        ],
      ),
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      body: widget.events.isEmpty
          ? Center(
        child: Text(
          'No events found.',
          style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
              fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: sortedEvents.length,
        itemBuilder: (context, dateIndex) {
          String date = sortedEvents[dateIndex].key;
          List eventList = sortedEvents[dateIndex].value;

          return Card(
            color: widget.isDarkMode
                ? Colors.grey[900]
                : Colors.grey[200],
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text(
                    date,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode ? Colors.white : Colors.black),
                  ),
                  value: selectedEvents[dateIndex],
                  onChanged: (value) {
                    setState(() {
                      selectedEvents[dateIndex] = value!;
                    });
                  },
                  secondary: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      if (eventList.length == 1) {
                        _editEvent(dateIndex, 0);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                            title: Text(
                              'Select Event to Edit',
                              style: TextStyle(
                                color: widget.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            content: Container(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: eventList.length,
                                itemBuilder: (context, eventIndex) {
                                  return ListTile(
                                    title: Text(
                                      eventList[eventIndex].toString(),
                                      style: TextStyle(
                                        color: widget.isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _editEvent(dateIndex, eventIndex);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                ...eventList.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                  child: Text(
                    e.toString(),
                    style: TextStyle(
                        fontSize: 16,
                        color: widget.isDarkMode
                            ? Colors.white70
                            : Colors.black87),
                  ),
                )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}