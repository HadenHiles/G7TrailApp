import 'package:flutter/widgets.dart';
import 'package:g7trailapp/navigation/ui/sprite.dart';

class AnimatedSprite extends AnimatedWidget {
  final ImageProvider image;
  final int frameWidth;
  final int frameHeight;

  const AnimatedSprite({
    Key? key,
    required this.image,
    required this.frameWidth,
    required this.frameHeight,
    required Animation<double> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Sprite(
      image: image,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      frame: animation.value,
    );
  }
}
