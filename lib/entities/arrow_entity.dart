import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:scuba_game/entity_modules/take_damage.dart';

class Arrow extends BodyComponent implements Damageable {
  final Vector2 initialPosition;
  final Vector2 initialDirection;

  Arrow({required this.initialPosition, required this.initialDirection});
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.dynamic,
      fixedRotation: true,
      angle: atan2(initialDirection.y, initialDirection.x),
      linearDamping: 0.0,
      angularDamping: 1.0,
      bullet: true,
    );

    final body = world.createBody(bodyDef);

    // 2. Create the "Core" rectangle
    final rectangle = PolygonShape()..setAsBox(1, 0.4, Vector2.zero(), 0);
    body.createFixture(
      FixtureDef(rectangle, density: 1.0)..filter.groupIndex = -1,
    );

    body.linearVelocity = initialDirection.scaled(30);

    return body;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 3. Attach the visual sprite as a child of the body
    final sprite = await Sprite.load('arrow.png');
    add(
      SpriteComponent(
        sprite: sprite,
        size: Vector2.all(3), // Match Forge2D meter scale
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void takeDamage(double amount) {
    removeFromParent();
  }

  @override
  double health = 10;
}
