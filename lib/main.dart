import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:flutter/material.dart';
import 'package:scuba_game/entities/cave_generation.dart';
import 'package:scuba_game/entities/coral_entity.dart';
import 'package:scuba_game/entities/player_entity.dart';
import 'package:scuba_game/entities/sky_background.dart';

void main() {
  runApp(GameWidget(game: MyPhysicsGame()));
}

class MyPhysicsGame extends Forge2DGame with HasKeyboardHandlerComponents {
  MyPhysicsGame() : super(gravity: Vector2(0, 0));

  late Player player;

  // @override
  // Color backgroundColor() => const Color.fromARGB(255, 0, 65, 91);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final world = World();
    await add(world);

    camera = CameraComponent(world: world);
    await add(camera);

    add(SkyBackground()..priority = -100);
    // Set the camera to look at the center of the world coordinates
    camera.viewfinder.anchor = Anchor.center;

    // Optional: Zoom out a bit since Forge2D meters are large
    camera.viewfinder.zoom = 10.0;

    // Add the CaveManager to the world. It will generate everything on its `onLoad`.
    await world.add(CaveManager());

    player = Player(initialPosition: Vector2(-4, 3));
    await world.add(player);
    camera.follow(player, snap: true);
  }

  // Inside your Manager or Game class
  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  bool get debugMode => false;
}
