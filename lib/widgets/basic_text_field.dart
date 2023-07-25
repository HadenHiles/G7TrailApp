import 'package:flutter/material.dart';

class BasicTextField extends StatefulWidget {
  const BasicTextField({Key? key, required this.hintText, required this.controller, required this.keyboardType, required this.validator}) : super(key: key);

  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  @override
  _BasicTextFieldState createState() => _BasicTextFieldState();
}

class _BasicTextFieldState extends State<BasicTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).textTheme.bodyLarge!.color,
      style: Theme.of(context).textTheme.bodyLarge,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintStyle: Theme.of(context).textTheme.bodyLarge,
        hintText: widget.hintText,
      ),
      controller: widget.controller,
      validator: widget.validator,
    );
  }
}
