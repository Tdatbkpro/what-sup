import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Avatarprofile extends StatelessWidget {
  final double radius;
  final String? ImgaeUrl;
  final double width;

  const Avatarprofile({
    super.key,
    required this.radius,
    this.ImgaeUrl,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;

    return Container(
      width: size + width,
      height: size + width,
      padding: EdgeInsets.all(width),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: width,
        ),
      ),
      child: ClipOval(
        child: ImgaeUrl == null || ImgaeUrl!.isEmpty
            ? CircleAvatar(
                radius: radius,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.person_outline_rounded, size: 24),
              )
            : CachedNetworkImage(
                imageUrl: ImgaeUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.grey[300],
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
      ),
    );
  }
}
