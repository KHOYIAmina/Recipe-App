import 'package:cloud_firestore/cloud_firestore.dart'; // Importer Timestamp depuis cloud_firestore
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recipe_app/Utils/constants.dart';
import 'package:recipe_app/Utils/theme_screen.dart';
import 'package:recipe_app/Views/view_all_items.dart';
import 'package:recipe_app/Widget/cart_meal.dart';
import 'package:iconsax/iconsax.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  Timestamp _selectedDate = Timestamp.fromDate(DateTime.now());

  DateTime _startOfWeek = DateTime.now();
  DateTime _endOfWeek = DateTime.now().add(const Duration(days: 4));

  // Function to get the formatted week range
  String getWeekRange() {
    String startDate = DateFormat('dd MMM').format(_startOfWeek);
    String endDate = DateFormat('dd MMM').format(_endOfWeek);
    print(startDate);
    return "$startDate - $endDate";
  }

  void _previousWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.subtract(const Duration(days: 5));
      _endOfWeek = _startOfWeek.add(const Duration(days: 4));
    });
  }

  void _nextWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.add(const Duration(days: 5));
      _endOfWeek = _startOfWeek.add(const Duration(days: 4));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            centerTitle: true,
            title: const Text(
              "Meal Plan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false),
        body: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: _startOfWeek.isAfter(DateTime.now())
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          onPressed: _startOfWeek.isAfter(DateTime.now())
                              ? _previousWeek
                              : null,
                        ),
                        Text(
                          getWeekRange(),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: _nextWeek,
                        ),
                      ],
                    ),

                    // Row for navigation buttons (previous and next week)
                    Container(
                      margin: const EdgeInsets.only(top: 7, left: 2),
                      child: DatePicker(
                        _startOfWeek,
                        height: 100,
                        width: 74,
                        initialSelectedDate: DateTime.now(),
                        selectionColor: Theme.of(context).colorScheme.primary,
                        selectedTextColor: Colors.white,
                        dateTextStyle: ThemeScreen.calendarStyle(size: 20),
                        dayTextStyle: ThemeScreen.calendarStyle(size: 16),
                        monthTextStyle: ThemeScreen.calendarStyle(size: 14),
                        onDateChange: (date) {
                          setState(() {
                            _selectedDate = Timestamp.fromDate(date);
                          });
                        },
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 10, left: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, dd MMMM')
                                  .format(_selectedDate.toDate()),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ViewAllItems(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(5),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(
                                  Iconsax.add,
                                  color: Colors.white,
                                  size: 20,
                                  semanticLabel: "Add Meal",
                                ),
                              ),
                            )
                          ],
                        ))
                  ],
                ),
              ),
              Expanded(
                child: CartMeal(
                  date: _selectedDate,
                ),
              ),
            ],
          ),
        ));
  }
}
