import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event.dart';



class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

List _listofEventDays(DateTime dateTime)
{
  if (myEvents)
}

class _CalendarState extends State<Calendar> {

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;


  showAddEventBottomSheet(){
    showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        builder: (context) => AddEvent(selectedDate: _selectedDay,)
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(90, 172, 239, 0.5019607843137255),
        centerTitle: true,
          title: const Text('CALENDAR', style: TextStyle( fontSize: 35, fontFamily: 'Cookie', color: Color.fromRGBO(0,  0, 0, 1)),),
      ),


      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/calendar.jpg', ), fit: BoxFit.cover)
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child:  DropdownButton<CalendarFormat>(
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
              ),
               Expanded(
                 child: Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: TableCalendar(focusedDay: DateTime.now() , firstDay: DateTime(1947), lastDay: DateTime(2035),
                     calendarFormat: _calendarFormat,
                     calendarStyle: CalendarStyle(
                         cellMargin: EdgeInsets.zero,
                       isTodayHighlighted: true,
                       defaultTextStyle: TextStyle(fontSize: 22, fontFamily: 'Cookie'), // Date numbers
                       weekendTextStyle: TextStyle(fontSize: 22, color: Colors.red.shade700, fontFamily: 'Cookie'),
                       todayTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cookie'),
                       weekNumberTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cookie'),
                       todayDecoration: BoxDecoration(
                         color: Color.fromRGBO(97, 190, 248, 0.7647058823529411),
                         shape: BoxShape.circle
                       ),
                       selectedDecoration: BoxDecoration(
                         color: Color.fromRGBO(
                             17, 79, 237, 0.6196078431372549),
                           shape: BoxShape.circle,
                       )),

                       daysOfWeekStyle: DaysOfWeekStyle(
                         weekdayStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                         weekendStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700)
                       ),

                       rowHeight: 70,daysOfWeekHeight: 50,
                         headerStyle: HeaderStyle( formatButtonVisible: false),

                       onDaySelected: (selectedDay, focusedDay) {
                         if(!isSameDay(_selectedDay, selectedDay))
                         {
                           setState((){
                             _selectedDay = selectedDay;
                             _focusedDay = focusedDay;
                         });
                         }
                       },
                       selectedDayPredicate: (day) {
                         return isSameDay(_selectedDay, day);
                       },

                       eventLoader: _listofEventDays,
                       ),
                 ),
                )

            ],
          ),

      ),
        floatingActionButton: FloatingActionButton.extended(backgroundColor: Color.fromRGBO(
            132, 197, 243, 0.6705882352941176),
        onPressed: () {
          showAddEventBottomSheet();
        },
    label: const Text(' Add Event :', style: TextStyle( fontSize: 30, fontFamily: 'Cookie', ),),
    ),
    );
  }
}


