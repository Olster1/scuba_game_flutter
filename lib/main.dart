import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:flutter/material.dart';
import 'package:scuba_game/entities/coral_entity.dart';
import 'package:scuba_game/entities/player_entity.dart';

void main() {
  runApp(GameWidget(game: MyPhysicsGame()));
}

class MyPhysicsGame extends Forge2DGame with HasKeyboardHandlerComponents {
  MyPhysicsGame() : super(gravity: Vector2(0, 0));

  final double _cameraSharpness = 5.0;

  late Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final world = World();
    await add(world);

    camera = CameraComponent(world: world);
    await add(camera);

    // 1. Load the background as a simple SpriteComponent
    final background = SpriteComponent(
      sprite: await Sprite.load('ocean_backdrop.png'),

      size: canvasSize,
    );

    // Set the camera to look at the center of the world coordinates
    camera.viewfinder.anchor = Anchor.center;

    // Optional: Zoom out a bit since Forge2D meters are large
    camera.viewfinder.zoom = 15.0;

    camera.backdrop.add(background);

    await world.add(Coral(initialPosition: Vector2(10, 10)));

    player = Player(initialPosition: Vector2(0, 0));
    await world.add(player);
    camera.follow(
      player,
      maxSpeed: 10, // The camera will "chase" the player at this speed
      snap: false,
    );
  }
}
