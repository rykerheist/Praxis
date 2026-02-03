import 'package:flutter/material.dart';

class PraxisLogo extends StatelessWidget {
  const PraxisLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // Phase 6.1: The Logo Asset
    // Implementation: Using a Text placeholder until asset is available
    // Ideally: Image.asset('assets/images/praxis_logo_header.png', height: 24);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'PRAXIS',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 24, 
            letterSpacing: 4.0,
            height: 1.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(bottom: 4),
          color: Theme.of(context).primaryColor,
        )
      ],
    );
  }
}
