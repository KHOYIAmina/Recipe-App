import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:recipe_app/Provider/notifs_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app/Utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:recipe_app/Views/recipe_detail_screen.dart';
import 'package:recipe_app/Widget/date_validator.dart';
import 'package:table_calendar/table_calendar.dart';

class CartMeal extends StatefulWidget {
  final Timestamp date; // Make date a final field passed via constructor

  const CartMeal({super.key, required this.date});

  @override
  _CartMealState createState() => _CartMealState();
}

class _CartMealState extends State<CartMeal> {
  final NotifsProvider providerNotifs = NotifsProvider();
  void refreshParent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final NotifsProvider providerNotifs = NotifsProvider();

    // Function to get the appropriate icon for each category
    IconData getCategoryIcon(String category) {
      switch (category.toLowerCase()) {
        case 'breakfast':
          return Icons.free_breakfast_outlined;
        case 'lunch':
          return Icons.lunch_dining_outlined;
        case 'dinner':
          return Icons.dinner_dining_outlined;
        default:
          return Icons.fastfood;
      }
    }

    // Define the preferred order of categories
    List<String> categoryOrder = ['Breakfast', 'Lunch', 'Dinner'];
    bool isShown = true;

    void delete(BuildContext context, DateTime date, String idDocs) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to remove the notification?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  setState(() {
                    providerNotifs.removeDateFromFirebase(date, idDocs);
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification removed successfully'),
                        backgroundColor: Colors.red, // Custom background color
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                },
                child: const Text('Yes'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('No'),
              ),
            ],
          );
        },
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: providerNotifs.fetchSelectedDates(widget.date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/Animation-meals.json', // Assurez-vous que ce chemin est correct
                width: 200,
                height: 200,
              ),
              const Text(
                'No meals found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ));
        } else {
          List<Map<String, dynamic>> results = snapshot.data!;

          // Grouping meals by category
          Map<String, List<Map<String, dynamic>>> groupedMeals = {};
          for (var result in results) {
            String category =
                result['category']?.toString().toLowerCase() ?? 'inconnue';
            if (!groupedMeals.containsKey(category)) {
              groupedMeals[category] = [];
            }
            groupedMeals[category]?.add(result);
          }

          // Sorting the categories to match the desired order (Breakfast, Lunch, Dinner)
          List<String> sortedCategories = [];
          // Add Breakfast, Lunch, and Dinner categories first if they exist
          for (var category in categoryOrder) {
            if (groupedMeals.containsKey(category)) {
              sortedCategories.add(category);
            }
          }
          // Add any remaining categories at the end (like snacks, etc.)
          for (var category in groupedMeals.keys) {
            if (!categoryOrder.contains(category)) {
              sortedCategories.add(category);
            }
          }

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.92,
            child: ListView.builder(
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                String category = sortedCategories[index];
                List<Map<String, dynamic>> categoryMeals =
                    groupedMeals[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            getCategoryIcon(category),
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.toUpperCase(), // Capitalize category name
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Meal cards for this category
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable scrolling for this inner ListView
                      itemCount: categoryMeals.length,
                      itemBuilder: (context, mealIndex) {
                        var meal = categoryMeals[mealIndex];
                        var recipeId = meal['id'] ?? 'ID inconnu';
                        var recipeName = meal['name'] ?? 'Recette inconnue';
                        var image = meal['image'] ?? 'Image inconnue';
                        var date = meal['date'].toDate() ?? 'Date inconnue';

                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                      documentSnapshot: meal['recipeSnapshot']),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(image),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipeName,
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Iconsax.flash_1,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              "${meal['cal']} Cal",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
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
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "${meal['time']} Min",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: kBannerColor
                                                    .withOpacity(0.76),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    meal['date'] is Timestamp
                                                        ? (DateFormat('HH:mm')
                                                                    .format((meal['date']
                                                                            as Timestamp)
                                                                        .toDate())
                                                                    .compareTo(
                                                                        '18:00') >=
                                                                0
                                                            ? Icons
                                                                .nightlight_outlined // Moon icon
                                                            : Icons
                                                                .wb_sunny_outlined) // Sun icon
                                                        : Icons
                                                            .error, // Error icon in case of invalid date
                                                    color: Colors
                                                        .white, // Icône blanche pour contraste avec le fond
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    meal['date'] is Timestamp
                                                        ? DateFormat('HH:mm')
                                                            .format((meal[
                                                                        'date']
                                                                    as Timestamp)
                                                                .toDate()) // Format the time
                                                        : 'Invalid Date', // Display 'Invalid Date' if the date is invalid
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors
                                                          .white, // Texte blanc pour contraste
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  DateValidatorWidget(
                                    date: date,
                                    recipeId: recipeId,
                                    onRefresh: refreshParent,
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }
}
