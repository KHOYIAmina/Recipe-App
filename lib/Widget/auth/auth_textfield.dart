import 'package:flutter/material.dart';

class AuthTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool isPassword;
  final bool isEmail;

  const AuthTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    bool? isPassword,
    bool? isEmail,
    this.icon,
  })  : isPassword = isPassword ?? false,
        isEmail = isEmail ?? false;

  @override
  _AuthTextfieldState createState() => _AuthTextfieldState();
}

class _AuthTextfieldState extends State<AuthTextfield> {
  late bool _passwordVisible;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _passwordVisible = true; // Initialize password visibility as hidden
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      obscureText: widget.isPassword ? _passwordVisible : false,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(800),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.tertiary,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: Theme.of(context).colorScheme.primary)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible; // Toggle visibility
                  });
                },
              )
            : null,
      ),
      validator: widget.isEmail
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            }
          : null,
    );

    // return Form(
    //   autovalidateMode: AutovalidateMode.onUnfocus,
    //   key: _formKey,
    //   child: TextFormField(
    //     controller: widget.controller,
    //     keyboardType: TextInputType.emailAddress,
    //     obscureText: widget.isPassword ? _passwordVisible : false,
    //     decoration: InputDecoration(
    //       border: OutlineInputBorder(
    //         borderRadius: BorderRadius.circular(800),
    //         borderSide: const BorderSide(
    //           width: 0,
    //           style: BorderStyle.none,
    //         ),
    //       ),
    //       filled: true,
    //       fillColor: Theme.of(context).colorScheme.tertiary,
    //       hintText: widget.hintText,
    //       hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
    //       prefixIcon: widget.icon != null
    //           ? Icon(widget.icon, color: Theme.of(context).colorScheme.primary)
    //           : null,
    //       suffixIcon: widget.isPassword
    //           ? IconButton(
    //               icon: Icon(
    //                 _passwordVisible ? Icons.visibility : Icons.visibility_off,
    //                 color: Theme.of(context).colorScheme.secondary,
    //               ),
    //               onPressed: () {
    //                 setState(() {
    //                   _passwordVisible = !_passwordVisible; // Toggle visibility
    //                 });
    //               },
    //             )
    //           : null,
    //     ),
    //     validator: widget.isEmail
    //         ? (value) {
    //             if (value == null || value.isEmpty) {
    //               return 'Please enter your email';
    //             }
    //             final emailRegex =
    //                 RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    //             if (!emailRegex.hasMatch(value)) {
    //               return 'Please enter a valid email';
    //             }
    //             return null;
    //           }
    //         : null,
    //   ),
    // );
  }
}
