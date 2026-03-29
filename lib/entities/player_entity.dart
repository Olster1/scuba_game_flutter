import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:scuba_game/entities/arrow_entity.dart';
import 'package:scuba_game/entity_modules/take_damage.dart';

class Player extends BodyComponent with KeyboardHandler implements Damageable {
  final Vector2 initialPosition;
  double _targetAngle = 0.0;
  final double _rotationSharpness = 8.0;

  Player({required this.initialPosition});
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.dynamic,
      fixedRotation: false,
      linearDamping: 1.5,
      angularDamping: 1.0,
    );

    final body = world.createBody(bodyDef);

    // 2. Create the "Core" rectangle
    final rectangle = PolygonShape()..setAsBox(4, 1, Vector2.zero(), 0);
    body.createFixture(
      FixtureDef(rectangle, density: 1.0)..filter.groupIndex = -1,
    );

    return body;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 3. Attach the visual sprite as a child of the body
    final sprite = await Sprite.load('player.png');
    add(
      SpriteComponent(
        sprite: sprite,
        size: Vector2.all(10), // Match Forge2D meter scale
        anchor: Anchor.center,
      ),
    );
  }

  void shootArrow() async {
    Arrow arrow = Arrow(
      initialPosition: body.position,
      initialDirection: Vector2(cos(body.angle), sin(body.angle)),
    );
    await parent?.add(arrow);
  }

  // 4. Handle Movement
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      shootArrow(); // Call your shooting logic here
    }

    return false;
  }

  void updateKeys() {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;

    Vector2 velocity = Vector2.zero();

    if (keys.contains(LogicalKeyboardKey.arrowLeft)) velocity.x -= 1;
    if (keys.contains(LogicalKeyboardKey.arrowRight)) velocity.x += 1;
    if (keys.contains(LogicalKeyboardKey.arrowUp)) velocity.y -= 1;
    if (keys.contains(LogicalKeyboardKey.arrowDown)) velocity.y += 1;

    const double speed = 50.0;

    // Apply linear velocity to the physics body
    body.linearVelocity = velocity.normalized() * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);

    updateKeys();

    final velocity = body.linearVelocity;

    if (velocity.length > 0.1) {
      _targetAngle = atan2(velocity.y, velocity.x);
    }

    // 1. Calculate the shortest distance between current and target angle
    double angleDiff = _targetAngle - body.angle;

    while (angleDiff <= -pi) angleDiff += 2 * pi;
    while (angleDiff > pi) angleDiff -= 2 * pi;

    if (dt > 0) {
      double desiredAngularVelocity =
          angleDiff * (1 - exp(-_rotationSharpness * dt)) / dt;

      // 4. Apply directly to the body
      body.angularVelocity = desiredAngularVelocity;
    }
  }

  @override
  void takeDamage(double amount) {}

  @override
  double health = 10;
}
