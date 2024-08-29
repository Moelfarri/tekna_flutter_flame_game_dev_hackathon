import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_flappy_bird/components/game.dart';
import 'package:flutter_flappy_bird/components/pipe.dart';

class PipeGroup extends PositionComponent
    with HasGameRef<FlutterFlappyBirdGame> {
  PipeGroup()
      : super(
          position: Vector2(30, 42),
          size: Vector2(10, 0),
        );
  @override
  FutureOr<void> onLoad() {
    Random random = Random();

    final height = random.nextDouble() * 15;

    position += Vector2(0, height);

    addAll([
      Pipe(pipePosition: PipePosition.top),
      Pipe(pipePosition: PipePosition.bottom),
    ]);

    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= 6 * dt;

    //when out of site dispawn

    if (position.x > game.camera.visibleWorldRect.right + 10 ||
        position.x < game.camera.visibleWorldRect.left - 10) {
      removeFromParent();
    }
  }
}
