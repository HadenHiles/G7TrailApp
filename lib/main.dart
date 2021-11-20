import 'package:flutter/material.dart';
import 'package:g7trailapp/navigation/nav.dart';

void main() {
  runApp(const G7Trail());
}

class G7Trail extends StatelessWidget {
  const G7Trail({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const FluidNavigationBar();
  }
}
