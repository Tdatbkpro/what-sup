import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final Tuple2<double, double> backGroundAvar;
  const UserAvatar({super.key, required this.imageUrl, required this.backGroundAvar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: backGroundAvar.item1,
            height: backGroundAvar.item2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              //color: Theme.of(context).colorScheme.primary,
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
          ),
          Container(
            width: backGroundAvar.item1 - 20,
            height: backGroundAvar.item2 - 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage( // ✅ Không dùng const ở đây
                image: imageUrl.contains("http") == false ? AssetImage(imageUrl) : NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
