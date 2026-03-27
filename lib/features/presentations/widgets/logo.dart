import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.isBig = false});

  final bool? isBig;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Click Menu',
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: isBig! ? 24 : 14,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ZEN ',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: isBig! ? 40 : 22,
              ),
            ),
            Image.asset('assets/images/leaf.png', width: isBig! ? 40 : 22),
          ],
        ),
      ],
    );
  }
}
