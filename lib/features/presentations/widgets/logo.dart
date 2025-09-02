import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class Logo extends StatelessWidget {
  const Logo({super.key,this.isBig = false});

  final bool? isBig;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Click Menu',
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: isBig! ? 40 : null
        ),
        children: [
          TextSpan(
            text: '\nZEN ',
            style: Theme.of(context).textTheme.headlineMedium!
                .copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
                fontSize: isBig! ? 40 : null
            ),
          ),
          WidgetSpan(
            child: Image.asset('assets/images/leaf.png', width: isBig! ? 40 : 20),
          ),
        ],
      ),
    );
  }
}
