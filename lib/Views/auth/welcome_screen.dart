import 'dart:math';

import 'package:flutter/material.dart';
import 'package:recipe_app/Views/auth/login_screen.dart';
import 'package:recipe_app/Views/auth/register_screen.dart';
import 'package:recipe_app/Widget/auth/auth_button.dart';
import 'package:recipe_app/models/models.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomePage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: _currentPage, viewportFraction: 0.8);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: const AssetImage('assets/images/welcome-no-filter.png'),
              fit: BoxFit.fitHeight,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.surface, BlendMode.screen),
              alignment: Alignment.topRight)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                ),

                const SizedBox(height: 10),

                Image.asset(
                  'assets/images/reciply.png',
                  width: 180,
                ),

                const SizedBox(height: 5),

                //message,app slogan
                Text(
                  'Your next great meal is just a tap away!\nLog in to explore delicious recipes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),

          // Slider
          AspectRatio(
            aspectRatio: 0.95,
            child: PageView.builder(
                itemCount: dataList.length,
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                itemBuilder: (context, index) {
                  return carouselView(index);
                }),
          ),

          // login/register buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25),
            child: Column(
              children: [
                // login button
                AuthButton(
                  text: 'Login',
                  isGradient: true,
                  btnOnPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
                const SizedBox(height: 10),

                AuthButton(
                  text: 'Sign up',
                  isGradient: false,
                  btnOnPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget carouselView(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = index.toDouble() - (_pageController.page ?? 0);
          value = (value * 0.038).clamp(-1, 1);
        }
        return Transform.rotate(
          angle: pi * value,
          child: carouselCard(dataList[index]),
        );
      },
    );
  }

  Widget carouselCard(DataModel data) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 300,
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Hero(
              tag: data.imageName,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                          image: AssetImage(
                            data.imageName,
                          ),
                          fit: BoxFit.cover),
                      boxShadow: const [
                        BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 8,
                            color: Colors.black12)
                      ]),
                ),
              ),
            ),
          ),
        ),
        Text(
          data.title,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primaryContainer,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
