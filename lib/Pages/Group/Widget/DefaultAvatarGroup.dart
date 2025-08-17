import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whats_up/Model/User.dart';
import 'package:whats_up/Pages/Chat/Widgets/AvatarProfile.dart';

class DefaultGroupAvatar extends StatelessWidget {
  final List<User> members;
  final double size;

  const DefaultGroupAvatar({
    Key? key,
    required this.members,
    this.size = 45.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = members.length;
    final visibleMembers = members.take(4).toList();
    final extraCount = count - 4;

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: _buildAvatars(visibleMembers, extraCount),
        ),
      ),
    );
  }

  List<Widget> _buildAvatars(List<User> members, int extraCount) {
    final List<Widget> widgets = [];

    if (members.length == 3) {
      final double avatarSize = size * 0.6;

      widgets.addAll([
        _avatar(members[0], Offset(size * 0.5 - avatarSize / 2, 0), avatarSize),
        _avatar(members[1], Offset(0, size * 0.5), avatarSize),
        _avatar(members[2], Offset(size - avatarSize, size * 0.5), avatarSize),
      ]);
    } else if (members.length >= 4) {
      final double avatarSize = size * 0.5;

      widgets.addAll([
        _avatar(members[0], Offset(0, 0), avatarSize),
        _avatar(members[1], Offset(size - avatarSize, 0), avatarSize),
        _avatar(members[2], Offset(0, size - avatarSize), avatarSize),
        extraCount > 0
            ? _extraAvatar(extraCount, Offset(size - avatarSize, size - avatarSize), avatarSize)
            : _avatar(members[3], Offset(size - avatarSize, size - avatarSize), avatarSize),
      ]);
    } else if (members.length == 2) {
      final double avatarSize = size * 0.65;

      widgets.addAll([
        _avatar(members[0], Offset(0, size * 0.15), avatarSize),
        _avatar(members[1], Offset(size * 0.35, size * 0.15), avatarSize),
      ]);
    } else if (members.length == 1) {
      final double avatarSize = size * 0.85;
      widgets.add(_avatar(members[0], Offset((size - avatarSize) / 2, (size - avatarSize) / 2), avatarSize));
    }

    return widgets;
  }

  Widget _avatar(User user, Offset offset, double avatarSize) {
    final color = Colors.primaries[user.hashCode % Colors.primaries.length];

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: ClipOval(
        child: Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.profileImage == null ? color : null,
            image: user.profileImage != null
                ? DecorationImage(
                    image:
                     CachedNetworkImageProvider(
                       user.profileImage!,
                     ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: user.profileImage == null
              ? Text(
                  user.name![0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: avatarSize * 0.4,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _extraAvatar(int count, Offset offset, double avatarSize) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        alignment: Alignment.center,
        child: Text(
          '+$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: avatarSize * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
