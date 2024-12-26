import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/Views/app_main_screen.dart';
import 'package:recipe_app/Views/auth/register_screen.dart';
import 'package:recipe_app/Widget/auth/auth_button.dart';
import 'package:recipe_app/Widget/auth/auth_social.dart';
import 'package:recipe_app/Widget/auth/auth_textfield.dart';
import 'package:recipe_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

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
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.push(
            (context),
            MaterialPageRoute(builder: (context) => const AppMainScreen()),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connexion réussie'),
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
          // padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                'Welcome Back to Reciply',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),

              //message,app slogan
              Text(
                'Log in to explore delicious recipes and manage your personalized meal plans.',
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
                  child: Column(children: [
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
                  ])),

              const SizedBox(height: 100),

              // login button
              if (_isLoading)
                const CircularProgressIndicator()
              else
                AuthButton(
                  text: 'Login',
                  isGradient: true,
                  btnOnPressed: _submitForm,
                ),
              const SizedBox(height: 10),

              // not a member? register now

              Text(
                'Don\'t have an account?',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),

              const SizedBox(height: 5),

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
                text: 'Sign in with Google',
                btnOnPressed: _signInWithGoogle,
              )
            ],
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
