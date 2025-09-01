import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'explosion.dart';
import '../tank_game.dart';

class Eagle extends SpriteComponent with HasGameReference<TankGame>, CollisionCallbacks {
  bool isDestroyed = false;
  
  Eagle({required Vector2 position}) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load eagle sprite - show only the first frame (intact eagle)
    final spriteSheet = await game.images.load('sprites/eagle.png');
    sprite = Sprite(spriteSheet, srcPosition: Vector2.zero(), srcSize: Vector2(32, 32));
    
    size = Vector2(64, 64);
    anchor = Anchor.center;
    
    // Add collision detection
    add(RectangleHitbox());
  }
  
  void destroy() {
    if (isDestroyed) return;
    
    isDestroyed = true;
    
    // Change to destroyed sprite (second frame)
    final spriteSheet = game.images.fromCache('sprites/eagle.png');
    sprite = Sprite(spriteSheet, srcPosition: Vector2(32, 0), srcSize: Vector2(32, 32));
    
    // Create explosion effect
    final explosion = Explosion(position: position.clone());
    parent?.add(explosion);
    
    // Notify game that eagle is destroyed
    game.eagleDestroyed();
    
    // Remove eagle after a short delay to show destroyed sprite
    final removeTimer = TimerComponent(
      period: 1.0,
      onTick: () => removeFromParent(),
    );
    add(removeTimer);
  }
}