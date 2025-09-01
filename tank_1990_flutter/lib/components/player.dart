import 'package:flame/components.dart';
import 'tank.dart';

class Player extends Tank {
  bool isMoving = false;
  
  Player({required Vector2 position}) 
    : super(
          position: position,
          spritePath: 'sprites/player.png',
          initialDirection: Direction.up,
      );
  
  @override
  void explode() {
    super.explode();
    if (game != null) {
      game.playerDestroyed();
    }
  }
}