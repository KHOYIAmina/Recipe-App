import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/Views/app_main_screen.dart';
import 'package:recipe_app/Views/auth/login_screen.dart';
import 'package:recipe_app/Widget/auth/auth_button.dart';
import 'package:recipe_app/Widget/auth/auth_social.dart';
import 'package:recipe_app/Widget/auth/auth_textfield.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.push(
          (context),
          MaterialPageRoute(builder: (context) => const AppMainScreen()),
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Créer un document utilisateur dans Firestore
        await _userService.createUser(userCredential.user!.uid, {
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          Navigator.push(
            (context),
            MaterialPageRoute(builder: (context) => const AppMainScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Une erreur est survenue'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 25),

              // Login Title
              Text(
                'Join Reciply Today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),

              //message,app slogan
              Text(
                'Discover a world of amazing recipes and take control of your meal planning.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              const SizedBox(height: 25),

              Form(
                autovalidateMode: AutovalidateMode.onUnfocus,
                key: _formKey,
                child: Column(
                  children: [
                    //email textfield
                    AuthTextfield(
                      controller: _usernameController,
                      hintText: 'Enter Username',
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 10),

                    //email textfield
                    AuthTextfield(
                      controller: _emailController,
                      hintText: 'Enter Email',
                      icon: Icons.email_outlined,
                      isEmail: true,
                    ),

                    const SizedBox(height: 10),

                    //password textfield
                    AuthTextfield(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 75),

              // not a member? register now
              AuthButton(
                text: 'Sign up',
                isGradient: true,
                btnOnPressed: _submitForm,
              ),

              const SizedBox(height: 10),

              Text(
                'Already have an account? Login',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),

              const SizedBox(height: 5),

              // login button
              AuthButton(
                text: 'Login',
                isGradient: false,
                btnOnPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),

              const SizedBox(height: 25),
              // google login button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(children: <Widget>[
                  Expanded(
                    child:
                        Divider(color: Theme.of(context).colorScheme.secondary),
                  ),
                  Text(" OR ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                  Expanded(
                    child:
                        Divider(color: Theme.of(context).colorScheme.secondary),
                  ),
                ]),
              ),

              const SizedBox(height: 25),

              AuthSocial(
                text: 'Sign up with Google',
                btnOnPressed: _signInWithGoogle,
              ),
            ],
          ),
        )
      ]),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
