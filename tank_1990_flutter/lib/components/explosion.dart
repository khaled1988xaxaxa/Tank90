import 'package:flame/components.dart';

class Explosion extends SpriteAnimationComponent with HasGameReference {
  Explosion({required Vector2 position}) : super(position: position);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load explosion sprite sheet
    final spriteSheet = await game.images.load('sprites/explosion.png');
    
    // Create animation from sprite sheet
    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 8, // Number of frames in explosion animation
        stepTime: 0.1,
        textureSize: Vector2(64, 64),
        loop: false,
      ),
    );
    
    size = Vector2(64, 64);
    anchor = Anchor.center;
    
    // Play explosion sound
    // FlameAudio.play('sounds/explosion.wav'); // TODO: Implement audio
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Remove explosion when animation completes
    final ticker = animationTicker;
    if (ticker != null && (ticker.completed == true)) {
      removeFromParent();
    }
  }
}