import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Order Screen'),),
    );
  }
}