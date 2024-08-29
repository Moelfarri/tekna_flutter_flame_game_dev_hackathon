import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

const playerSize = 5.0;
const flapAngle = 0.5;

class Player extends BodyComponent {
  Player(Vector2 position, Sprite sprite)
      : _sprite = sprite,
        super(
          renderBody: false,
          bodyDef: BodyDef()
            ..bullet = true
            ..position = position
            ..type = BodyType.dynamic
            ..angularDamping = 0.1
            ..linearDamping = 0.1,
          fixtureDefs: [
            FixtureDef(CircleShape()..radius = 10 / 2)
              ..restitution = 0.4
              ..density = 0.75
              ..friction = 0.5
          ],
        );

  final Sprite _sprite;

  @override
  Future<void> onLoad() {
    addAll([
      SpriteComponent(
        anchor: Anchor.center,
        sprite: _sprite,
        size: Vector2(playerSize, playerSize),
        position: Vector2(0, 0),
      ),
    ]);

    //  add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (body.angle.abs() > flapAngle) {
      body.angularVelocity = 0.0;
    }

    //if body accelerates downwards (gravity), rotate the player downwards
    if (body.linearVelocity.y > 0 && body.angle < flapAngle) {
      body.applyAngularImpulse(25);
    }

    //if body accelerates upwards (gravity), rotate the player downwards
    if (body.linearVelocity.y < 0 && body.angle > -flapAngle) {
      body.angularVelocity = -3;
    }
  }
}

class CollidablePlayer extends PositionComponent with CollisionCallbacks {
  CollidablePlayer(Vector2 position, Sprite sprite)
      : _sprite = sprite,
        super(
          position: Vector2(-5, 0),
          size: Vector2(playerSize, playerSize),
        );

  final Sprite _sprite;
  late final Player player;

  @override
  Future<void> onLoad() async {
    player = Player(position, _sprite);
    addAll([
      player,
      CircleHitbox(
        radius: playerSize / 2,
      ),
    ]);

    super.onLoad();
  }

  //collision detection not working properly.
  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    print('Collided!');
  }
}
