import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FoodsScreen extends StatelessWidget {
  const FoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Food Screen'),),
    );
  }
}