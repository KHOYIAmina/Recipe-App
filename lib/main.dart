import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/Provider/favorite_provider.dart';
import 'package:recipe_app/Provider/quantity.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/Views/auth/login_screen.dart';
import 'package:recipe_app/Views/auth/welcome_screen.dart';
import 'package:recipe_app/themes/theme_provider.dart';
import 'Views/app_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // runApp(const MyApp());
  runApp(MultiProvider(providers: [
    // for favorite provider
    ChangeNotifierProvider(create: (_) => FavoriteProvider()),
    // for quantity provider
    ChangeNotifierProvider(create: (_) => QuantityProvider()),
    // for theme provider
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return MultiProvider(
    //   providers: [
    //     // for favorite provider
    //     ChangeNotifierProvider(create: (_) => FavoriteProvider()),
    //     // for quantity provider
    //     ChangeNotifierProvider(create: (_) => QuantityProvider()),
    //     // for theme provider
    //     ChangeNotifierProvider(create: (context) => ThemeProvider()),
    //   ],
    //   child: MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: LoginPage(),
    //     theme: Provider.of<ThemeProvider>(context).themeData,
    //   ),
    // );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
