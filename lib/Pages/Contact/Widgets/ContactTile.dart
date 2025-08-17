import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Contacttile extends StatelessWidget {
  final IconData iconContact;
  final String nameContact;

  const Contacttile({
    super.key,
    required this.iconContact,
    required this.nameContact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200), // Giới hạn chiều rộng
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            iconContact,
            size: 22,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AutoSizeText(
              nameContact,
              maxLines: 1,
              minFontSize: 8,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          )

        ],
      ),
    );
  }
}

