import 'package:flutter/material.dart';

class DecorationText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const DecorationText({
    Key? key,
    required this.text, required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white
          ),
    );
  }
}
