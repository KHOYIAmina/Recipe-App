import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/Utils/constants.dart';
import 'package:recipe_app/Views/auth/login_screen.dart';
import 'package:recipe_app/Views/favorite_screen.dart';
import 'package:recipe_app/Views/meal_plan_screen.dart';
import 'package:recipe_app/Views/my_app_home_screen.dart';
import 'package:iconsax/iconsax.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    page = [
      const MyAppHomeScreen(),
      const FavoriteScreen(),
      const MealPlanScreen(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (value) async {
          if (value == 3) {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext ctx) {
                return CupertinoAlertDialog(
                  title: const Text('Please Confirm'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        setState(() async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
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
          } else {
            setState(() {
              selectedIndex = value;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 0 ? Iconsax.home5 : Iconsax.home_1,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
            ),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.calendar5 : Iconsax.calendar,
            ),
            label: "Meal Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Iconsax.logout : Iconsax.logout,
            ),
            label: "Logout",
          ),
        ],
      ),
      body: page[selectedIndex],
    );
  }
}
