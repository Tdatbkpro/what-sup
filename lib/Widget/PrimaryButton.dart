import 'package:flutter/material.dart';

class Primarybutton extends StatelessWidget {
  final String btnName;
  final IconData btnIcon;
  final VoidCallback? onTap;

  const Primarybutton({
    super.key,
    required this.btnName,
    required this.btnIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: colorScheme.primary.withOpacity(0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: colorScheme.onPrimary.withOpacity(0.2),
        highlightColor: colorScheme.onPrimary.withOpacity(0.1),
        child: Container(
          height: 56,
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(btnIcon, color: colorScheme.onPrimary, size: 24),
              const SizedBox(width: 12),
              Text(
                btnName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
