import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:scuba_game/entity_modules/take_damage.dart';

class Coral extends BodyComponent implements Damageable {
  final Vector2 initialPosition;

  Coral({required this.initialPosition});
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.static,
      fixedRotation: true,
      linearDamping: 1.0,
      angularDamping: 1.0,
    );

    final body = world.createBody(bodyDef);

    // 2. Create the "Core" rectangle
    final rectangle = PolygonShape()..setAsBox(2, 2, Vector2.zero(), 0);
    body.createFixture(FixtureDef(rectangle, density: 1.0));

    return body;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 3. Attach the visual sprite as a child of the body
    final sprite = await Sprite.load('coral.png');
    add(
      SpriteComponent(
        sprite: sprite,
        size: Vector2.all(10), // Match Forge2D meter scale
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void takeDamage(double amount) {
    health -= amount;
    removeFromParent();
  }

  @override
  double health = 10;
}
