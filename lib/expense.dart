import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ntasks/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// ======================
// NotificationHelper commented out entirely
// ======================
// class NotificationHelper {
//   static final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     tz.initializeTimeZones();
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: android);
//     await _notifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         print('Notification response: ${response.payload}');
//       },
//     );
//   }
//
//   static Future<void> scheduleDailyExpenseReminder() async {
//     await _notifications.zonedSchedule(
//       0,
//       'Expense Reminder',
//       'Don\'t forget to log today\'s expenses 💰',
//       _nextInstanceOfTenPM(),
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'expense_reminder',
//           'Expense Reminder',
//           channelDescription: 'Daily reminder to add expenses',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//   static tz.TZDateTime _nextInstanceOfTenPM() {
//     final now = tz.TZDateTime.now(tz.local);
//     var scheduledDate =
//         tz.TZDateTime(tz.local, now.year, now.month, now.day, 22);
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }
//     return scheduledDate;
//   }
//
//   static Future<void> showLowBalanceAlert() async {
//     await _notifications.show(
//       1,
//       'Low Balance Alert 🚨',
//       'Your balance is below ₹500. Please review your spending!',
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'low_balance',
//           'Low Balance Alert',
//           channelDescription: 'Alerts when balance is low',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//     );
//   }
//
//   static Future<void> showExpenseAddedNotification(double amount, String description) async {
//     await _notifications.show(
//       2,
//       'Expense Added 💸',
//       '₹${amount.toStringAsFixed(2)} spent on $description',
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'expense_added',
//           'Expense Added',
//           channelDescription: 'Notifies when an expense is logged',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//     );
//   }
// }

class ExpenseTracker extends StatefulWidget {
  @override
  _ExpenseTrackerState createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _addMoneyController = TextEditingController();

  List<Map<String, dynamic>> _expenses = [];
  double _totalIncome = 0.0;
  bool _hasSetInitialBalance = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // await NotificationHelper.init();
    // await NotificationHelper.scheduleDailyExpenseReminder();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expensesJson = prefs.getString('expenses');
    double? savedIncome = prefs.getDouble('totalIncome');
    bool? setOnce = prefs.getBool('hasSetInitialBalance');

    if (expensesJson != null) {
      setState(() {
        _expenses = List<Map<String, dynamic>>.from(jsonDecode(expensesJson));
      });
    }

    if (savedIncome != null) setState(() => _totalIncome = savedIncome);
    if (setOnce != null) setState(() => _hasSetInitialBalance = setOnce);

    // if (_hasSetInitialBalance && (_totalIncome - _totalExpenses) < 500) {
    //   NotificationHelper.showLowBalanceAlert();
    // }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenses', jsonEncode(_expenses));
    await prefs.setDouble('totalIncome', _totalIncome);
    await prefs.setBool('hasSetInitialBalance', _hasSetInitialBalance);
  }

  void _addExpense(double amount, String description) {
    setState(() {
      final expense = {
        'amount': amount,
        'description': description,
        'date': DateTime.now().toIso8601String(),
      };
      _expenses.add(expense);
    });
    _saveData();

    // NotificationHelper.showExpenseAddedNotification(amount, description);

    if ((_totalIncome - _totalExpenses) < 500) {
      // NotificationHelper.showLowBalanceAlert();
    }
  }

  void _addMoney(double amount) {
    setState(() {
      _totalIncome += amount;
    });
    _saveData();
  }

  double _calculateTotalForDate(DateTime date) {
    return _expenses
        .where((e) => DateTime.parse(e['date']).day == date.day &&
        DateTime.parse(e['date']).month == date.month &&
        DateTime.parse(e['date']).year == date.year)
        .fold(0.0, (sum, e) => sum + (e['amount'] as num));
  }

  double _calculateTotalForMonth(DateTime date) {
    return _expenses
        .where((e) =>
    DateTime.parse(e['date']).month == date.month &&
        DateTime.parse(e['date']).year == date.year)
        .fold(0.0, (sum, e) => sum + (e['amount'] as num));
  }

  List<BarChartGroupData> _buildBarData() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final total = _calculateTotalForDate(day);
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: total, color: Colors.orangeAccent)
      ]);
    });
  }

  double get _totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + (e['amount'] as num));

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daily = _calculateTotalForDate(now);
    final monthly = _calculateTotalForMonth(now);
    final savings = _totalIncome - _totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker", style: TextStyle(fontFamily: 'Cardo')),
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
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (!_hasSetInitialBalance)
                    Column(
                      children: [
                        Text("Enter Your Starting Balance (₹)", style: _textStyle(context: context)),
                        SizedBox(height: 8),
                        TextField(
                          controller: _addMoneyController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("₹"),
                          onSubmitted: (value) {
                            final entered = double.tryParse(value);
                            if (entered != null) {
                              setState(() {
                                _totalIncome = entered;
                                _hasSetInitialBalance = true;
                              });
                              _addMoneyController.clear();
                              _saveData();
                            }
                          },
                        ),
                        SizedBox(height: 12),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _addMoneyController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration("Add Money (₹)"),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final entered = double.tryParse(_addMoneyController.text);
                                if (entered != null) {
                                  _addMoney(entered);
                                  _addMoneyController.clear();
                                }
                              },
                              child: Text("Add"),
                            )
                          ],
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  Text("Daily Expense: ₹${daily.toStringAsFixed(2)}", style: _textStyle(context: context)),
                  Text("Monthly Expense: ₹${monthly.toStringAsFixed(2)}", style: _textStyle(context: context)),
                  Text("Total Spent: ₹${_totalExpenses.toStringAsFixed(2)}", style: _textStyle(context: context)),
                  Text(
                    "Current Balance: ₹${savings.toStringAsFixed(2)}",
                    style: _textStyle(
                      color: savings < 500
                          ? Colors.red
                          : Theme.of(context).textTheme.bodyLarge?.color, context: context,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 250,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toString() + 'k',
                                  style: TextStyle(fontSize: 12),
                                  maxLines: 1,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value < 0 || value > 6) return const Text('');
                                final day = DateTime.now()
                                    .subtract(Duration(days: 6 - value.toInt()));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "${day.day}/${day.month}",
                                    style: TextStyle(fontSize: 12),
                                    maxLines: 1,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarData(),
                        gridData: FlGridData(show: true),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Expense Amount (₹)'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    decoration: _inputDecoration('Description'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(_amountController.text);
                      if (amount != null && _descController.text.trim().isNotEmpty) {
                        _addExpense(amount, _descController.text.trim());
                        _amountController.clear();
                        _descController.clear();
                      }
                    },
                    child: Text("Add Expense"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.white),
                  Text("Expenses List", style: _textStyle(context: context)),
                  if (_expenses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No expenses added yet",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    ..._expenses.reversed.map((e) {
                      final date = DateTime.parse(e['date']);
                      return Card(
                        color: Colors.white70,
                        child: ListTile(
                          title: Text(
                            "₹${e['amount']} - ${e['description']}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "${date.day}/${date.month}/${date.year}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text("Delete Expense"),
                                  content: Text("Are you sure you want to delete this expense?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _expenses.remove(e);
                                        });
                                        _saveData();
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
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
