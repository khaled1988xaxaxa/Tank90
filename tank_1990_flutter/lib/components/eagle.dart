import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'explosion.dart';

class Eagle extends SpriteAnimationComponent with HasGameReference, CollisionCallbacks {
  bool isDestroyed = false;
  
  Eagle({required Vector2 position}) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load eagle sprite
    final spriteSheet = await game.images.load('sprites/eagle.png');
    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.5,
        textureSize: Vector2(32, 32),
      ),
    );
    
    size = Vector2(64, 64);
    anchor = Anchor.center;
    
    // Add collision detection
    add(RectangleHitbox());
  }
  
  void destroy() {
    if (isDestroyed) return;
    
    isDestroyed = true;
    
    // Create explosion effect
    final explosion = Explosion(position: position.clone());
    parent?.add(explosion);
    
    // Notify game that eagle is destroyed
    // gameRef.eagleDestroyed(); // TODO: Implement game reference
    
    // Remove eagle
    removeFromParent();
  }
}