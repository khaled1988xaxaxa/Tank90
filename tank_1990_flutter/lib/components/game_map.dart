import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'bullet.dart';

class GameMap extends Component with HasGameReference {
  late List<List<int>> mapData;
  final List<Brick> bricks = [];
  
  static const int tileSize = 30;
  static const int mapWidth = 30;
  static const int mapHeight = 30;
  
  @override
  Future<void> onLoad() async {
    await _loadMapData();
    _createBricks();
  }
  
  Future<void> _loadMapData() async {
    // Load map.json file
    final mapJson = await rootBundle.loadString('assets/map.json');
    final mapObject = json.decode(mapJson);
    
    // Extract tile data from the first layer
    final layerData = mapObject['layers'][0]['data'] as List<dynamic>;
    
    // Convert to 2D array
    mapData = [];
    for (int y = 0; y < mapHeight; y++) {
      final row = <int>[];
      for (int x = 0; x < mapWidth; x++) {
        final index = y * mapWidth + x;
        row.add(layerData[index] as int);
      }
      mapData.add(row);
    }
  }
  
  void _createBricks() {
    for (int y = 0; y < mapHeight; y++) {
      for (int x = 0; x < mapWidth; x++) {
        if (mapData[y][x] == 1) {
          // Create brick at this position
          final brick = Brick(
            position: Vector2(
              x * tileSize.toDouble() + tileSize / 2,
              y * tileSize.toDouble() + tileSize / 2,
            ),
            gridX: x,
            gridY: y,
          );
          bricks.add(brick);
          add(brick);
        }
      }
    }
  }
  
  void destroyBrick(int gridX, int gridY) {
    // Find and remove brick at grid position
    bricks.removeWhere((brick) {
      if (brick.gridX == gridX && brick.gridY == gridY) {
        brick.removeFromParent();
        mapData[gridY][gridX] = 0;
        return true;
      }
      return false;
    });
    
    // Play destroy sound
      // FlameAudio.play('images/sounds/destroyTile.wav'); // Disabled for web compatibility
  }
  
  bool isBrickAt(int gridX, int gridY) {
    if (gridX < 0 || gridX >= mapWidth || gridY < 0 || gridY >= mapHeight) {
      return false;
    }
    return mapData[gridY][gridX] == 1;
  }
  
  Vector2 worldToGrid(Vector2 worldPos) {
    return Vector2(
      (worldPos.x / tileSize).floor().toDouble(),
      (worldPos.y / tileSize).floor().toDouble(),
    );
  }
  
  Vector2 gridToWorld(int gridX, int gridY) {
    return Vector2(
      gridX * tileSize.toDouble() + tileSize / 2,
      gridY * tileSize.toDouble() + tileSize / 2,
    );
  }
}

class Brick extends SpriteComponent with CollisionCallbacks, HasGameReference {
  final int gridX;
  final int gridY;
  
  Brick({
    required Vector2 position,
    required this.gridX,
    required this.gridY,
  }) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('sprites/brick.png');
    size = Vector2(GameMap.tileSize.toDouble(), GameMap.tileSize.toDouble());
    anchor = Anchor.center;
    
    // Add collision detection
    add(RectangleHitbox());
  }
  
  @override
  bool onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      // Bullet hits brick - destroy the brick
      (parent as GameMap).destroyBrick(gridX, gridY);
      other.removeFromParent();
      return true;
    }
    return true;
  }
}