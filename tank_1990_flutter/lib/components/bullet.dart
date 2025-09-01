import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'tank.dart';
import 'eagle.dart';
import 'explosion.dart';
import 'game_map.dart';
import 'enemy_tank.dart';
import 'player.dart';

class Bullet extends SpriteComponent with HasGameReference, CollisionCallbacks {
  final Vector2 velocity;
  final Tank owner;
  
  Bullet({
    required Vector2 position,
    required this.velocity,
    required this.owner,
  }) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load bullet sprite
    final spriteSheet = await game.images.load('sprites/bullet.png');
    sprite = Sprite(spriteSheet);
    
    size = Vector2(8, 8);
    anchor = Anchor.center;
    
    // Add collision detection
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Move bullet
    position += velocity * dt;
    
    // Remove bullet if it goes out of bounds
    if (position.x < 0 || position.x > 800 ||
        position.y < 0 || position.y > 600) {
      removeFromParent();
    }
  }
  
  @override
  bool onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Tank && other != owner) {
      // Check for friendly fire - enemies should not damage other enemies
      if (owner is EnemyTank && other is EnemyTank) {
        print('LOG: Friendly fire prevented - Enemy bullet hit another enemy');
        print('LOG: Bullet owner: ${owner.runtimeType}, Target: ${other.runtimeType}');
        return true; // Don't explode, just pass through
      }
      
      // Log all bullet hits
      print('LOG: Bullet collision - Owner: ${owner.runtimeType}, Target: ${other.runtimeType}');
      
      // Hit a tank (valid target)
      other.explode();
      _explode();
      return false;
    } else if (other is Eagle) {
      // Hit the eagle
      print('LOG: Bullet hit Eagle - Owner: ${owner.runtimeType}');
      other.destroy();
      _explode();
      return false;
    } else if (other is Bullet && other != this) {
      // Hit another bullet
      print('LOG: Bullet collision - ${owner.runtimeType} bullet vs ${(other as Bullet).owner.runtimeType} bullet');
      other._explode();
      _explode();
      return false;
    } else if (other is Brick) {
      // Hit a brick wall - destroy it
      print('LOG: Bullet hit Brick - Owner: ${owner.runtimeType}');
      _explode();
      return false;
    }
    return true;
  }
  
  void _explode() {
    // Create explosion effect
    final explosion = Explosion(position: position.clone());
    parent?.add(explosion);
    
    // Remove bullet
    removeFromParent();
  }
}