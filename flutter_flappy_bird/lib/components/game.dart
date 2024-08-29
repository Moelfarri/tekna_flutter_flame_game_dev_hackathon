import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flappy_bird/components/pipe_group.dart';
import 'package:flutter_flappy_bird/components/player.dart';

import 'background.dart';

class FlutterFlappyBirdGame extends Forge2DGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  FlutterFlappyBirdGame()
      : super(
          gravity: Vector2(0, 10),
          camera: CameraComponent.withFixedResolution(width: 400, height: 400),
        );

  late CollidablePlayer _player;
  late Timer _timer;

  @override
  FutureOr<void> onLoad() async {
    // - Background:
    final backgroundImage = await images.load('flappy_background.png');
    await world.add(
      Background(
        sprite: Sprite(
          backgroundImage,
        ),
      ),
    );

    // -  Player:
    final playerSprite = await images.load('bird.png');
    _player = CollidablePlayer(
      Vector2(
        camera.visibleWorldRect.left * 2 / 3, 0,
        //box
      ),
      Sprite(
        playerSprite,
      ),
    );

    world.add(_player);

    // - Spawn new pipes every 6 seconds:
    world.add(PipeGroup());
    _timer = Timer.periodic(const Duration(milliseconds: 6000), (_) {
      final pipeGroup = PipeGroup();
      world.add(pipeGroup);
    });

    return super.onLoad();
  }

  @override
  onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _player.player.body.linearVelocity = Vector2(0, 0);
        _player.player.body.angularVelocity = 0;

        _player.player.body.applyLinearImpulse(Vector2(0, -650));
      }
    }

    return event is KeyDownEvent
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }
}
