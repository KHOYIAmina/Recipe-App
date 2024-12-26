import 'package:flutter/material.dart';

class AuthSocial extends StatelessWidget {
  final String text;
  final VoidCallback btnOnPressed;
  const AuthSocial({super.key, required this.text, required this.btnOnPressed});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(800.0)),
          ),
          child: ElevatedButton(
            iconAlignment: IconAlignment.start,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
            onPressed: btnOnPressed,
            child: Row(children: [
              Image.network(
                  'http://pngimg.com/uploads/google/google_PNG19635.png',
                  fit: BoxFit.cover,
                  width: 30,
                  height: 30),
              const SizedBox(width: 10),
              Text(text,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary)),
            ]),
          ),
        ),
      )
    ]);
  }
}
