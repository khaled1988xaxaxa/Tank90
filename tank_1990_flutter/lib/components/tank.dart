import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import '../tank_game.dart';
import 'bullet.dart';
import 'explosion.dart';

enum Direction { up, down, left, right }

abstract class Tank extends SpriteAnimationComponent
    with HasGameReference<TankGame>, CollisionCallbacks {
  late Direction direction;
  late Vector2 spawnPoint;
  final String spritePath;
  double speed = 180.0;
  bool canFire = true;
  Timer? fireTimer;
  Vector2? _previousPosition;
  
  Tank({
    required Vector2 position,
    required this.spritePath,
    required Direction initialDirection,
  }) : super(position: position) {
    direction = initialDirection;
    spawnPoint = position.clone();
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load sprite animation
    final spriteSheet = await game.images.load(spritePath);
    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2(spriteSheet.width / 2, spriteSheet.height.toDouble()),
      ),
    );
    
    size = Vector2(55, 55);
    anchor = Anchor.center;
    
    // Add collision detection
    add(RectangleHitbox());
    
    // Set initial rotation based on direction
    _updateRotation();
  }
  
  void moveUp(double dt) {
    _storePreviousPosition();
    direction = Direction.up;
    _updateRotation();
    final newY = position.y - speed * dt;
    if (newY >= size.y / 2) {
      position.y = newY;
      _playMoveAnimation();
    }
  }
  
  void moveDown(double dt) {
    _storePreviousPosition();
    direction = Direction.down;
    _updateRotation();
    final newY = position.y + speed * dt;
    if (newY <= game.size.y - size.y / 2) {
      position.y = newY;
      _playMoveAnimation();
    }
  }
  
  void moveLeft(double dt) {
    _storePreviousPosition();
    direction = Direction.left;
    _updateRotation();
    final newX = position.x - speed * dt;
    if (newX >= size.x / 2) {
      position.x = newX;
      _playMoveAnimation();
    }
  }
  
  void moveRight(double dt) {
    _storePreviousPosition();
    direction = Direction.right;
    _updateRotation();
    final newX = position.x + speed * dt;
    if (newX <= game.size.x - size.x / 2) {
      position.x = newX;
      _playMoveAnimation();
    }
  }
  
  void moveForward(double dt) {
    switch (direction) {
      case Direction.up:
        moveUp(dt);
        break;
      case Direction.down:
        moveDown(dt);
        break;
      case Direction.left:
        moveLeft(dt);
        break;
      case Direction.right:
        moveRight(dt);
        break;
    }
  }
  
  void changeDirection() {
    final random = Random();
    final directions = Direction.values;
    Direction newDirection;
    
    do {
      newDirection = directions[random.nextInt(directions.length)];
    } while (newDirection == direction);
    
    direction = newDirection;
    _updateRotation();
  }
  
  void _updateRotation() {
    switch (direction) {
      case Direction.up:
        angle = -pi / 2;
        break;
      case Direction.down:
        angle = pi / 2;
        break;
      case Direction.left:
        angle = pi;
        break;
      case Direction.right:
        angle = 0;
        break;
    }
  }
  
  void _playMoveAnimation() {
    if (animationTicker != null) {
      animationTicker!.reset();
    }
  }
  
  void _storePreviousPosition() {
    _previousPosition = position.clone();
  }
  
  void _revertPosition() {
    if (_previousPosition != null) {
      position = _previousPosition!.clone();
    }
  }
  
  void fire() {
    if (!canFire) return;
    
    canFire = false;
    final timerComponent = TimerComponent(
      period: 0.5,
      onTick: () {
        canFire = true;
      },
    );
    add(timerComponent);
    
    // Calculate bullet spawn position
    Vector2 bulletPosition = position.clone();
    Vector2 bulletVelocity = Vector2.zero();
    
    const bulletSpeed = 400.0;
    
    switch (direction) {
      case Direction.up:
        bulletPosition.y -= size.y / 2;
        bulletVelocity = Vector2(0, -bulletSpeed);
        break;
      case Direction.down:
        bulletPosition.y += size.y / 2;
        bulletVelocity = Vector2(0, bulletSpeed);
        break;
      case Direction.left:
        bulletPosition.x -= size.x / 2;
        bulletVelocity = Vector2(-bulletSpeed, 0);
        break;
      case Direction.right:
        bulletPosition.x += size.x / 2;
        bulletVelocity = Vector2(bulletSpeed, 0);
        break;
    }
    
    final bullet = Bullet(
      position: bulletPosition,
      velocity: bulletVelocity,
      owner: this,
    );
    
    parent?.add(bullet);
    
    // Play fire sound
    // game.playSound('fire'); // TODO: Implement audio
  }
  
  void explode() {
    // Create explosion effect
    final explosion = Explosion(position: position.clone());
    parent?.add(explosion);
    
    // Play explosion sound
      // FlameAudio.play('images/sounds/explosion.wav'); // Disabled for web compatibility
    
    // Remove tank
    removeFromParent();
  }
  
  void setZeroVelocity() {
    // This method exists for compatibility with the original code
    // In Flame, we don't use velocity directly like in Phaser
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    fireTimer?.update(dt);
    
    // Keep tank within game bounds
    position.x = position.x.clamp(size.x / 2, TankGame.gameWidth - size.x / 2);
    position.y = position.y.clamp(size.y / 2, TankGame.gameHeight - size.y / 2);
  }
  
  @override
  bool onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Tank && other != this) {
      // Tank collision - stop movement and change direction
      _revertPosition();
      changeDirection();
      return false;
    } else if (other.runtimeType.toString().contains('Brick')) {
      // Brick collision - stop movement and change direction
      _revertPosition();
      changeDirection();
      return false;
    }
    return true;
  }
}