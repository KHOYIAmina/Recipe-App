import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final bool isGradient;
  final VoidCallback btnOnPressed;

  const AuthButton({
    super.key,
    required this.text,
    required this.btnOnPressed,
    bool? isGradient,
  }) : isGradient = isGradient ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(800.0)),
          gradient: isGradient
              ? const LinearGradient(
                  colors: [Color(0xFF5BEEC2), Color(0xFF36D6A4)])
              : null),
      child: ElevatedButton(
        onPressed: btnOnPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: isGradient
                ? Colors.transparent
                : Theme.of(context).colorScheme.tertiary,
            shadowColor: Colors.transparent),
        child: Text(text,
            style: TextStyle(
                color: isGradient
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.primaryContainer)),
      ),
    );
  }
}
