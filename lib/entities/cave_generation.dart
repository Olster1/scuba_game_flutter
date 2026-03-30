import 'dart:ui' as ui;
import 'package:fast_noise/fast_noise.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class CaveManager extends Component with HasGameRef<Forge2DGame> {
  final int rows = 1000;
  final int cols = 1000;
  final double tileSize = 0.08;
  final double threshold = -0.8;

  SpriteComponent? farLayer;
  SpriteComponent? midLayer;
  SpriteComponent? frontLayer;

  Future<ui.Image> _generateLayerImage({
    required List<List<double>> noiseData,
    required double threshold,
    required Color mainColor,
    required Color edgeColor,
    bool drawEdges = true,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (noiseData[y][x] < threshold) {
          if (drawEdges && _isEdge(noiseData, x, y)) {
            paint.color = edgeColor;
          } else {
            paint.color = mainColor;
          }

          canvas.drawRect(
            Rect.fromLTWH(
              x * tileSize,
              y * tileSize,
              tileSize,
              tileSize,
            ).inflate(0.5),
            paint,
          );
        }
      }
    }

    final picture = recorder.endRecording();
    return await picture.toImage(
      (cols * tileSize).toInt(),
      (rows * tileSize).toInt(),
    );
  }

  @override
  Future<void> onLoad() async {
    final noiseData = noise2(
      cols,
      rows,
      seed: 1337,
      noiseType: NoiseType.cellular,
      frequency: 0.01,
    );

    Color mainColor = const Color(0xFF001727); // Solid
    Color edgeColor = Colors.green;

    // Layer 1: The Furthest (Smallest, most transparent)
    final imgFar = await _generateLayerImage(
      noiseData: noiseData,
      threshold: threshold, // Stricter threshold = smaller shapes
      mainColor: mainColor.withAlpha(100),
      edgeColor: edgeColor,
      drawEdges: false,
    );

    // Layer 2: Mid-ground
    final imgMid = await _generateLayerImage(
      noiseData: noiseData,
      threshold: threshold,
      mainColor: mainColor.withAlpha(10),
      edgeColor: edgeColor,
      drawEdges: false,
    );

    // Layer 3: Foreground (The one with Physics)
    final imgFront = await _generateLayerImage(
      noiseData: noiseData,
      threshold: threshold,
      mainColor: mainColor,
      edgeColor: edgeColor,
      drawEdges: true,
    );

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (noiseData[y][x] < threshold) {
          bool edge = _isEdge(noiseData, x, y);

          // 2. Add Physics ONLY to the edges
          if (edge) {
            parent?.add(
              PhysicsCollider(
                position: Vector2(x * tileSize, y * tileSize),
                size: tileSize,
              ),
            );
          }
        }
      }
    }

    // Add them to the world with different priorities
    farLayer = SpriteComponent(
      sprite: Sprite(imgFar),
      priority: -3,
      position: Vector2(0, 0),
    );
    midLayer = SpriteComponent(
      sprite: Sprite(imgMid),
      priority: -2,
      position: Vector2(0, 0),
    );
    frontLayer = SpriteComponent(sprite: Sprite(imgFront), priority: -1);

    await parent?.add(farLayer!);
    parent?.add(midLayer!);
    parent?.add(frontLayer!);

    farLayer?.position = (Vector2(10, 10));
  }

  bool _isEdge(List<List<double>> data, int x, int y) {
    if (x <= 0 || y <= 0 || x >= cols - 1 || y >= rows - 1) return true;
    return data[y - 1][x] > threshold ||
        data[y + 1][x] > threshold ||
        data[y][x - 1] > threshold ||
        data[y][x + 1] > threshold;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 2. Calculate the "Difference" (Current Camera - Start Camera)
    final currentCam = gameRef.camera.viewfinder.position;
    //TODO: Get actual position of sprite in world position
    final delta = currentCam - Vector2(0, 0);

    // print(currentCam);

    // Far layer moves at 80% of the camera's travel
    farLayer?.position.setFrom(delta * 0.1);

    // // Mid layer moves at 50% of the camera's travel
    midLayer?.position.setFrom(delta * 0.01);

    // // Front layer stays at 0,0 because it matches the physics
    frontLayer?.position.setZero();
  }
}

// Keep the PhysicsCollider simple and WITHOUT a render method
class PhysicsCollider extends BodyComponent {
  final Vector2 position;
  final double size;
  PhysicsCollider({required this.position, required this.size});

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(size / 2, size / 2);
    return world.createBody(
      BodyDef(
        type: BodyType.static,
        position: position + Vector2.all(size / 2),
      ),
    )..createFixture(FixtureDef(shape));
  }

  @override
  void render(Canvas canvas) {} // Empty! The SpriteComponent handles visuals.
}
