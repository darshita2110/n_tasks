import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Added for ImageFilter

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({Key? key}) : super(key: key);

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  double? bmi;
  String? category;
  bool isDarkMode = false;
  String selectedGender = 'Male';

  void calculateBmi() {
    final double? height = double.tryParse(heightController.text);
    final double? weight = double.tryParse(weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      setState(() {
        bmi = null;
        category = "Enter valid numbers";
      });
      return;
    }

    final double bmiValue = weight / ((height / 100) * (height / 100));
    setState(() {
      bmi = bmiValue;
      category = _getBmiCategory(bmiValue);
    });
  }

  String _getBmiCategory(double bmiValue) {
    if (bmiValue < 18.5) return "Underweight";
    if (bmiValue < 24.9) return "Normal";
    if (bmiValue < 29.9) return "Overweight";
    return "Obese";
  }

  Color _getBmiColor() {
    if (bmi == null) return Colors.grey;
    if (bmi! < 18.5) return Colors.blue;
    if (bmi! < 24.9) return Colors.green;
    if (bmi! < 29.9) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
    final theme = Theme.of(context);

    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("BMI Calculator"),
          centerTitle: true,
          backgroundColor: Colors.teal.withOpacity(0.7),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => isDarkMode = !isDarkMode),
            ),
          ],
        ),
        body: SizedBox( height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/hi.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Male"),
                            selected: selectedGender == 'Male',
                            onSelected: (val) => setState(() => selectedGender = 'Male'),
                            selectedColor: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Female"),
                            selected: selectedGender == 'Female',
                            onSelected: (val) => setState(() => selectedGender = 'Female'),
                            selectedColor: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: InputDecoration(
                        labelText: "Height (cm)",
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: InputDecoration(
                        labelText: "Weight (kg)",
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: InputDecoration(
                        labelText: "Age",
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: calculateBmi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Calculate BMI", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 24),
                    if (bmi != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "BODY MASS INDEX METER",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Stack(
                              children: [
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Colors.green,
                                        Colors.orange,
                                        Colors.red,
                                      ],
                                      stops: const [0.2, 0.4, 0.6, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                if (bmi != null)
                                  Positioned(
                                    left: (bmi! / 40) * MediaQuery.of(context).size.width * 0.8,
                                    child: Container(
                                      height: 40,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("<18.5", style: TextStyle(fontSize: 12)),
                                Text("18.5-24.9", style: TextStyle(fontSize: 12)),
                                Text("25-29.9", style: TextStyle(fontSize: 12)),
                                Text("30+", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Underweight", style: TextStyle(fontSize: 12)),
                                Text("Normal", style: TextStyle(fontSize: 12)),
                                Text("Overweight", style: TextStyle(fontSize: 12)),
                                Text("Obese", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Your BMI: ${bmi!.toStringAsFixed(1)}",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: _getBmiColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Category: $category",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: _getBmiColor(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          selectedGender == 'Male'
                              ? "For men, a healthy BMI is typically between 18.5 and 24.9."
                              : "For women, BMI ranges are similar but body fat % differs.",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}