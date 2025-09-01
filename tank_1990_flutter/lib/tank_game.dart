import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'components/game_map.dart';
import 'components/player.dart';
import 'components/eagle.dart';
import 'components/enemy_tank.dart';
import 'components/bullet.dart';
import 'game_data.dart';
import 'package:flutter/services.dart';

class TankGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late GameMap gameMap;
  late Player player;
  late Eagle eagle;
  final List<EnemyTank> enemies = [];
  final List<Bullet> bullets = [];
  
  static const double gameWidth = 900.0;
  static const double gameHeight = 900.0;
  
  TimerComponent? enemySpawnTimer;
  int enemiesSpawned = 0;
  bool gameOver = false;
  bool victory = false;

  @override
  Future<void> onLoad() async {
    // Configure camera for proper viewport
    camera.viewfinder.visibleGameSize = Vector2(gameWidth, gameHeight);
    
    // Load and create the game map
    gameMap = GameMap();
    await add(gameMap);
    
    // Create the eagle (base to protect)
    eagle = Eagle(position: Vector2(420, 840));
    await add(eagle);
    
    // Create the player tank
    player = Player(position: Vector2(330, 870));
    await add(player);
    
    // Keyboard input will be handled in onKeyEvent
    
    // Start spawning enemies
    _startEnemySpawning();
    
    // Preload audio
    await _preloadAudio();
  }
  
  Future<void> _preloadAudio() async {
    // await FlameAudio.audioCache.loadAll([
    //   'sounds/move.wav',
    //   'sounds/fire.wav',
    //   'sounds/explosion.wav',
    //   'sounds/destroyTile.wav',
    //   'sounds/hold.wav',
    // ]); // TODO: Implement audio preloading
  }
  

  
  void _startEnemySpawning() {
    enemySpawnTimer = TimerComponent(
      period: 6.0,
      repeat: true,
      onTick: () {
        if (enemiesSpawned < GameData.enemiesToSpawn && enemies.length < 3) {
          _spawnEnemy();
        }
        
        if (enemiesSpawned >= GameData.enemiesToSpawn && enemies.isEmpty) {
          _victory();
          enemySpawnTimer?.timer.stop();
        }
      },
    );
    add(enemySpawnTimer!);
    
    // Spawn initial enemies
    for (int i = 0; i < 3 && i < GameData.enemiesToSpawn; i++) {
      _spawnEnemy();
    }
  }
  
  void _spawnEnemy() {
    if (enemiesSpawned >= GameData.enemiesToSpawn) return;
    
    final spawnPoints = [
      Vector2(30, 30),
      Vector2(430, 10),
      Vector2(840, 10),
    ];
    
    final spawnPoint = spawnPoints[enemiesSpawned % spawnPoints.length];
    final enemy = EnemyTank(position: spawnPoint);
    enemies.add(enemy);
    add(enemy);
    enemiesSpawned++;
  }
  
  void removeEnemy(EnemyTank enemy) {
    enemies.remove(enemy);
    enemy.removeFromParent();
    
    if (enemies.isEmpty && enemiesSpawned >= GameData.enemiesToSpawn) {
      _victory();
    }
  }
  
  void addBullet(Bullet bullet) {
    bullets.add(bullet);
    add(bullet);
  }
  
  void removeBullet(Bullet bullet) {
    bullets.remove(bullet);
    bullet.removeFromParent();
  }
  
  void _gameOver() {
    if (gameOver) return;
    gameOver = true;
    enemySpawnTimer?.timer.stop();
    
    // Add game over logic here
    print('Game Over!');
  }
  
  void _victory() {
    if (victory) return;
    victory = true;
    enemySpawnTimer?.timer.stop();
    
    // Add victory logic here
    print('Victory!');
  }
  
  void playSound(String soundName) {
    // TODO: Implement audio playback
    // FlameAudio.play('sounds/$soundName.wav');
  }
  
  void playerDestroyed() {
    _gameOver();
  }
  
  void eagleDestroyed() {
    _gameOver();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameOver || victory) return;
    
    // Handle player input using HardwareKeyboard
     final keyboard = HardwareKeyboard.instance;
     bool isMoving = false;
     
     if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowUp) ||
         keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyW)) {
       player.moveUp(dt);
       isMoving = true;
     }
     
     if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowDown) ||
         keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyS)) {
       player.moveDown(dt);
       isMoving = true;
     }
     
     if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowLeft) ||
         keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyA)) {
       player.moveLeft(dt);
       isMoving = true;
     }
     
     if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowRight) ||
         keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyD)) {
       player.moveRight(dt);
       isMoving = true;
     }
     
     if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.space)) {
       player.fire();
     }
     
     player.isMoving = isMoving;
    
    // Clean up bullets that are out of bounds
    bullets.removeWhere((bullet) {
      if (bullet.position.x < 0 || bullet.position.x > gameWidth ||
          bullet.position.y < 0 || bullet.position.y > gameHeight) {
        bullet.removeFromParent();
        return true;
      }
      return false;
    });
  }
  
  @override
  void onRemove() {
    enemySpawnTimer?.timer.stop();
    super.onRemove();
  }
}