import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_flappy_bird/components/game.dart';

class Pipe extends SpriteComponent with HasGameRef<FlutterFlappyBirdGame> {
  Pipe({
    required this.pipePosition,
  });

  final PipePosition pipePosition;

  @override
  Future<void> onLoad() async {
    final pipeRotated = await game.images.load('pipe.png');
    sprite = Sprite(pipeRotated);

    switch (pipePosition) {
      case PipePosition.top:
        addAll([
          SpriteComponent(
            sprite: Sprite(pipeRotated),
            position: Vector2(0, -64), //60 til 75
            anchor: Anchor.center,
            size: Vector2(5, 25),
          ),
          RectangleHitbox(
            position: Vector2(0, -30), //25 til 35
            anchor: Anchor.center,
            size: Vector2(5, 25),
          ),
        ]);

      case PipePosition.bottom:
        addAll(
          [
            SpriteComponent(
              sprite: Sprite(pipeRotated),
              position: Vector2(0, -30), //25 til 35
              anchor: Anchor.center,
              size: Vector2(5, 25),
              scale: Vector2(1, -1),
            ),
            RectangleHitbox(
              position: Vector2(0, -30), //25 til 35
              anchor: Anchor.center,
              size: Vector2(5, 25),
            ),
          ],
        );
    }
    super.onLoad();
  }
}

enum PipePosition {
  top,
  bottom,
}
