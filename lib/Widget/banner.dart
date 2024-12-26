import 'package:flutter/material.dart';
import 'package:recipe_app/Utils/constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipe_app/services/notifs_service.dart';

class BannerToExplore extends StatefulWidget {
  const BannerToExplore({super.key});

  @override
  State<BannerToExplore> createState() => _BannerToExploreState();
}

class _BannerToExploreState extends State<BannerToExplore> {
  Map<String, dynamic>? recent;
  NotifsService notifsService = NotifsService();
  @override
  void initState() {
    super.initState();
    fetchAndPrintMostRecentDate();
  }

  void fetchAndPrintMostRecentDate() async {
    try {
      List<Map<String, dynamic>>? mostRecent =
          await notifsService.fetchMostRecentDateWithRecipe();
      recent = mostRecent.first;
      print(recent);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: kBannerColor,
        image: DecorationImage(
            image: NetworkImage(
              recent?['image'], // image from firestore
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary, BlendMode.overlay),
            opacity: 0.2,
            alignment: Alignment.topRight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Next Meal.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recent?['name'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.flash_1,
                              size: 20,
                              color: Colors.white,
                            ),
                            Text(
                              "${recent?['cal']} Cal",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              " · ",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const Icon(
                              Iconsax.clock,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${recent?['time']} Min",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          recent?['dateRecipe'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          recent?['timeRecipe'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 0.7),
                        ),
                      ],
                    ),
                  ]),
            ),
          ],
        ),
      ),
      // Stack(
      //   children: [
      //     Positioned(
      //       top: 32,
      //       left: 20,
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           const Text(
      //             "Cook the best\nrecipes at home",
      //             style: TextStyle(
      //               height: 1.1,
      //               fontSize: 22,
      //               fontWeight: FontWeight.bold,
      //               color: Colors.white,
      //             ),
      //           ),
      //           const SizedBox(height: 10),
      //           ElevatedButton(
      //             style: ElevatedButton.styleFrom(
      //               padding: const EdgeInsets.symmetric(
      //                 horizontal: 33,
      //               ),
      //               backgroundColor: Colors.white,
      //               elevation: 0,
      //             ),
      //             onPressed: () {},
      //             child: const Text(
      //               "Explore",
      //               style: TextStyle(
      //                 fontSize: 15,
      //                 fontWeight: FontWeight.bold,
      //                 color: Colors.black,
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Positioned(
      //       top: 0,
      //       bottom: 0,
      //       right: -20,
      //       child: Image.network(
      //         "https://pngimg.com/d/chef_PNG190.png",
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
