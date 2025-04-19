import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ntasks/todo_list.dart';
import 'package:ntasks/calendar.dart';
import 'package:ntasks/expense.dart' ;
import 'package:ntasks/medicine.dart';
import 'package:ntasks/theme_provider.dart';
import 'package:ntasks/notes.dart';
import 'package:ntasks/time.dart';

const MaterialColor customDarkBlue = MaterialColor(
  0xFF00008B,
  <int, Color>{
    50: Color(0xFFE0E0F5),
    100: Color(0xFFB3B3E0),
    200: Color(0xFF8080CC),
    300: Color(0xFF4D4DB8),
    400: Color(0xFF2626A3),
    500: Color(0xFF00008B),
    600: Color(0xFF00007E),
    700: Color(0xFF000070),
    800: Color(0xFF000062),
    900: Color(0xFF00004A),
  },
);

class NotesAndSongsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NotesPage();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Homepage' ,
      themeMode: themeProvider.currentTheme,
      theme: ThemeData(
        primarySwatch: customDarkBlue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: customDarkBlue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/icon2.png'),
            ),
            Expanded(child: SizedBox(width: 10)),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Home Page',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Color.fromRGBO(0, 0, 120, 1.0),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
        backgroundColor: Color.fromRGBO(74, 107, 241, 0.6),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 28.0),
                child: Center(
                  child: Text(
                    'What you want to do ?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Cookie'),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 300,
                        height: 80,
                        child:
                        HomeButton(title: 'To-Do List', page: ToDoList())),
                    SizedBox(
                        width: 300,
                        height: 80,
                        child: HomeButton(
                            title: 'Events & Calendar', page: Calendar())),
                    SizedBox(
                        width: 300,
                        height: 80,
                        child: HomeButton(
                            title: 'Expense Tracker',
                            page: ExpenseTracker())),
                    SizedBox(
                        width: 300,
                        height: 80,
                        child: HomeButton(
                            title: 'Notes keeper', page: NotesPage())),
                    SizedBox(
                        width: 300,
                        height: 80,
                        child: HomeButton(
                            title: 'Time Tracker', page: TimeTrackerPage())),
                    SizedBox(
                        width: 300,
                        height: 80,
                        child: HomeButton(
                            title: 'Medicine Tracker', page: MedicineTracker())),
                  ],
                ),
              ),
              Container(
                height: 30,
                color: Colors.blueGrey.shade800,
                child: Center(
                  child: Text(
                    'Thank   You   for   visiting !',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Cookie'),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final String title;
  final Widget page;

  HomeButton({required this.title, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(
          title,
          style: TextStyle(fontSize: 32, fontFamily: 'Cookie'),
        ),
      ),
    );
  }
}
