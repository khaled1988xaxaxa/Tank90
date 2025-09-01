import 'dart:math';
import 'package:flame/components.dart';
import 'tank.dart';

class EnemyTank extends Tank {
  late TimerComponent _directionTimer;
  late TimerComponent _fireTimer;
  final Random _random = Random();
  
  EnemyTank({required Vector2 position})
      : super(
          position: position,
          spritePath: 'sprites/enemy.png',
          initialDirection: Direction.down,
        );
  
@override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Set up AI timers
    _directionTimer = TimerComponent(
      period: 2.0 + _random.nextDouble() * 3.0,
      repeat: true,
      onTick: () => changeDirection(),
    );
    add(_directionTimer);
    
    _fireTimer = TimerComponent(
      period: 1.0 + _random.nextDouble() * 2.0,
      repeat: true,
      onTick: () => fire(),
    );
    add(_fireTimer);
    
    // AI will handle movement in update method
  }
  

  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Move forward continuously
    moveForward(dt);
    
    // Fire when blocked by walls or other obstacles
    if (_isBlocked()) {
      fire();
      changeDirection();
    }
  }
  
  bool _isBlocked() {
    // Simple collision detection - check if tank is near boundaries
    const margin = 30.0;
    
    switch (direction) {
      case Direction.up:
        return position.y <= margin;
      case Direction.down:
        return position.y >= 600 - margin; // Use hardcoded value instead of TankGame.gameHeight
      case Direction.left:
        return position.x <= margin;
      case Direction.right:
        return position.x >= 800 - margin; // Use hardcoded value instead of TankGame.gameWidth
    }
  }
  
  @override
  void explode() {
    super.explode();
    if (game != null) {
      game.removeEnemy(this);
    }
  }
  
  @override
  void onRemove() {
    _directionTimer.removeFromParent();
    _fireTimer.removeFromParent();
    super.onRemove();
  }
}