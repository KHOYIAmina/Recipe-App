import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:recipe_app/Utils/constants.dart';
import 'package:recipe_app/Widget/calendar_dialog.dart';
import 'package:recipe_app/Widget/my_icon_button.dart';
import 'package:recipe_app/Widget/quantity_increment_decrement.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:recipe_app/services/favorite_service.dart';
import 'package:recipe_app/services/notifs_service.dart';
import 'package:recipe_app/services/quantity.dart';

class RecipeDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  final String previousPage;
  final Map<String, dynamic>? DataMeals;
  const RecipeDetailScreen({
    super.key,
    required this.documentSnapshot,
    required this.previousPage,
    this.DataMeals,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final NotifsService notifsService = NotifsService();
  bool isTimerRunning = false;
  int remainingTimeInSeconds = 0; // Store remaining time in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _initializeSelectedDates();
    _loadTimerState(); // Load the saved timer state

    List<double> baseAmounts = widget.documentSnapshot['ingredientsAmount']
        .map<double>((amount) => double.parse(amount.toString()))
        .toList();
    Provider.of<QuantityProvider>(context, listen: false)
        .setBaseIngredientAmounts(baseAmounts);
  }

  void _saveTimerState() {
    FirebaseFirestore.instance
        .collection('timers')
        .doc(widget.documentSnapshot.id)
        .set({
      'remainingTimeInSeconds': remainingTimeInSeconds,
      'isTimerRunning': isTimerRunning,
      'lastUpdated': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  void _loadTimerState() async {
    DocumentSnapshot timerSnapshot = await FirebaseFirestore.instance
        .collection('timers')
        .doc(widget.documentSnapshot.id)
        .get();

    if (timerSnapshot.exists) {
      Map<String, dynamic> data = timerSnapshot.data() as Map<String, dynamic>;
      setState(() {
        isTimerRunning = data['isTimerRunning'] ?? false;
        remainingTimeInSeconds = data['remainingTimeInSeconds'] ?? 0;

        if (isTimerRunning) {
          DateTime lastUpdated = DateTime.parse(data['lastUpdated']);
          int elapsedSeconds = DateTime.now().difference(lastUpdated).inSeconds;
          remainingTimeInSeconds -= elapsedSeconds;

          if (remainingTimeInSeconds > 0) {
            _startTimer();
          } else {
            _finishTimer(); // Handle timer completion
          }
        }
      });
    }
  }

  void _startTimer() {
    setState(() {
      isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTimeInSeconds > 0) {
          remainingTimeInSeconds--;
          _saveTimerState(); // Sauvegarde l'état à chaque seconde
        } else {
          _stopTimer(); // Arrête le minuteur si le temps est écoulé
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      isTimerRunning = false;
    });
    _timer.cancel();
    _saveTimerState();
  }

  void _stopTimer() {
    _timer.cancel();
    setState(() {
      isTimerRunning = false;
      remainingTimeInSeconds = 0;
    });

    _saveTimerState();
  }

  void _finishTimer() {
    _timer.cancel();
    setState(() {
      isTimerRunning = false;
      remainingTimeInSeconds = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cooking time is complete!")),
    );

    // Delete the timer document from Firestore after timer finishes
    _deleteTimerState();

    _saveTimerState();
  }

  void _deleteTimerState() async {
    try {
      // Delete the timer document from Firestore
      await FirebaseFirestore.instance
          .collection('timers')
          .doc(widget.documentSnapshot.id)
          .delete();
    } catch (e) {
      // Handle any errors if the deletion fails
      print("Error deleting timer state: $e");
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _saveTimerState();
      _timer.cancel();
    }
    super.dispose();
  }

  List<DateTime> selectedDates = [];
  List<DateTime> selectedDatesAfterNow = [];

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarDialog(
          recipeId: widget.documentSnapshot.id,
          onDateSelected: (List<DateTime> selectedDays) async {
            setState(() {
              selectedDates = selectedDays;
            });
          },
        );
      },
    );
  }

  void _initializeSelectedDates() async {
    try {
      List<DateTime> dates = await notifsService
          .getSelectedDatesForRecipe(widget.documentSnapshot.id);
      setState(() {
        selectedDates = dates;
      });
    } catch (e) {
      print('Error initializing selected dates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteService.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(provider),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // for image
                Container(
                  height: MediaQuery.of(context).size.height / 2.1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        widget.documentSnapshot['image'],
                      ),
                    ),
                  ),
                ),
                // for back button
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      MyIconButton(
                          icon: Icons.arrow_back_ios_new,
                          pressed: () {
                            Navigator.pop(context);
                          }),
                      const Spacer(),
                      MyIconButton(
                        icon: selectedDates.isNotEmpty
                            ? Icons.notifications_active
                            : Icons.notifications_active_outlined,
                        color: selectedDates.isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black,
                        pressed: () => _showCalendarDialog(context),
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.width,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            // for drag handle
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.flash_1,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Text(
                        "${widget.documentSnapshot['cal']} Cal",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        " · ",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                      const Icon(
                        Iconsax.clock,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['time']} Min",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // for rating
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.documentSnapshot['rating'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("/5"),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['reviews'.toString()]} Reviews",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ingredients",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "How many servings?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      QuantityIncrementDecrement(
                        currentNumber: quantityProvider.currentNumber,
                        onAdd: () => quantityProvider.increaseQuantity(),
                        onRemov: () => quantityProvider.decreaseQuanity(),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  // list of ingredients
                  Column(
                    children: [
                      Row(
                        children: [
                          // ingredients images
                          Column(
                            children: widget
                                .documentSnapshot['ingredientsImage']
                                .map<Widget>(
                                  (imageUrl) => Container(
                                    height: 60,
                                    width: 60,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          imageUrl,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(width: 20),
                          // ingredients name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.documentSnapshot['ingredientsName']
                                .map<Widget>((ingredient) => SizedBox(
                                      height: 60,
                                      child: Center(
                                        child: Text(
                                          ingredient,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          // ingredient amount
                          const Spacer(),
                          Column(
                            children: quantityProvider.updateIngredientAmounts
                                .map<Widget>((amount) => SizedBox(
                                      height: 60,
                                      child: Center(
                                        child: Text(
                                          "${amount}gm",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton startCookingAndFavoriteButton(FavoriteService provider) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0, // This ensures no shadow is applied
      onPressed: () {
        if (!isTimerRunning && remainingTimeInSeconds > 0) {
          setState(() {
            isTimerRunning = true;
            _startTimer();
          });
        } else if (isTimerRunning) {
          setState(() {
            isTimerRunning = false;
          });
          _pauseTimer();
        } else {
          setState(() {
            remainingTimeInSeconds = widget.documentSnapshot['time'] * 60;
            isTimerRunning = true;
          });
          _startTimer();
        }
      },
      label: Row(
        children: [
          SizedBox(
            width: 300,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: kprimaryColor,
                borderRadius: BorderRadius.circular(13.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isTimerRunning)
                    IconButton(
                      icon: const Icon(
                        Iconsax.pause,
                        size: 20,
                      ),
                      onPressed: () {
                        _pauseTimer();
                      },
                    )
                  else if (remainingTimeInSeconds > 0)
                    IconButton(
                      icon: const Icon(
                        Iconsax.play,
                        size: 20,
                      ),
                      onPressed: () {
                        _startTimer();
                      },
                    ),
                  const SizedBox(width: 10),
                  Text(
                    isTimerRunning
                        ? "Cooking Time: ${_formatElapsedTime(remainingTimeInSeconds)}"
                        : remainingTimeInSeconds > 0
                            ? "Timer Paused: ${_formatElapsedTime(remainingTimeInSeconds)}"
                            : "Start Cooking",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  (isTimerRunning || remainingTimeInSeconds > 0)
                      ? IconButton(
                          icon: const Icon(
                            Iconsax.stop,
                            size: 20,
                          ),
                          onPressed: () {
                            _stopTimer();
                          },
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              provider.isExist(widget.documentSnapshot)
                  ? Iconsax.heart5
                  : Iconsax.heart,
              color: provider.isExist(widget.documentSnapshot)
                  ? Colors.red
                  : Colors.black,
              size: 22,
            ),
            onPressed: () {
              provider.toggleFavorite(widget.documentSnapshot);
            },
          ),
        ],
      ),
    );
  }

  String _formatElapsedTime(int remainingTimeInSeconds) {
    int minutes = remainingTimeInSeconds ~/ 60;
    int seconds = remainingTimeInSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}
