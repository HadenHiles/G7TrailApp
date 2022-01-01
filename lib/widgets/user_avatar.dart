import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/models/firestore/user_profile.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({Key? key, this.user, this.radius, this.backgroundColor}) : super(key: key);

  final UserProfile? user;
  final double? radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (user!.photoUrl != null && user!.photoUrl!.contains('http')) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.antiAlias,
        child: CircleAvatar(
          radius: radius,
          backgroundImage: CachedNetworkImageProvider(
            user!.photoUrl!,
          ),
          backgroundColor: backgroundColor,
        ),
      );
    } else if (user!.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.antiAlias,
        child: Transform.scale(
          scale: user!.photoUrl!.contains('characters') ? 1.03 : 0.98,
          child: CircleAvatar(
            radius: radius,
            child: Image(
              image: AssetImage(user!.photoUrl!),
            ),
            backgroundColor: backgroundColor,
          ),
        ),
      );
    } else {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.antiAlias,
        child: CircleAvatar(
          radius: radius,
          backgroundImage: const AssetImage("assets/images/avatar.png"),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}
