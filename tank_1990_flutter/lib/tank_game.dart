import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'components/game_map.dart';
import 'components/player.dart';
import 'components/eagle.dart';
import 'components/enemy_tank.dart';
import 'components/bullet.dart';
import 'components/ui_overlay.dart';
import 'components/victory_screen.dart';
import 'components/game_over_screen.dart';
import 'components/main_menu.dart';
import 'components/multiplayer_screen.dart';
import 'components/map_creator_screen.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'package:flutter/services.dart';

class TankGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late GameMap gameMap;
  Player? player;
  late Eagle eagle;
  late UIOverlay uiOverlay;
  final List<EnemyTank> enemies = [];
  final List<Bullet> bullets = [];
  
  static const double gameWidth = 900.0;
  static const double gameHeight = 900.0;
  
  TimerComponent? enemySpawnTimer;
  int enemiesSpawned = 0;
  bool gameOver = false;
  bool victory = false;
  
  VictoryScreen? victoryScreen;
  GameOverScreen? gameOverScreen;
  MainMenu? mainMenu;
  MultiplayerScreen? multiplayerScreen;
  MapCreatorScreen? mapCreatorScreen;
  bool showingMenu = true;

  @override
  Future<void> onLoad() async {
    // Configure camera for proper viewport
    camera.viewfinder.visibleGameSize = Vector2(gameWidth, gameHeight);
    
    // Show main menu initially
    showMainMenu();
    
    // Preload audio
    await _preloadAudio();
  }
  
  Future<void> _initializeGame() async {
    // Load and create the game map
    gameMap = GameMap();
    await add(gameMap);
    
    // Create the eagle (base to protect)
    eagle = Eagle(position: Vector2(420, 840));
    await add(eagle);
    
    // Create the player tank
    player = Player(position: Vector2(330, 870));
    add(player!);
    
    // Create UI overlay
    uiOverlay = UIOverlay();
    await add(uiOverlay);
    
    // Start spawning enemies
    _startEnemySpawning();
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
    
    // Show game over screen
    gameOverScreen = GameOverScreen();
    add(gameOverScreen!);
    
    print('Game Over!');
  }
  
  void _victory() {
    if (victory) return;
    victory = true;
    enemySpawnTimer?.timer.stop();
    
    // Show victory screen
    victoryScreen = VictoryScreen();
    add(victoryScreen!);
    
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
  
  void _restartGame() {
    // Reset game state
    gameOver = false;
    victory = false;
    showingMenu = false;
    enemiesSpawned = 0;
    
    // Remove all existing components
    enemies.clear();
    bullets.clear();
    
    // Remove screens if they exist
    victoryScreen?.removeFromParent();
    gameOverScreen?.removeFromParent();
    victoryScreen = null;
    gameOverScreen = null;
    
    // Reset game data
    GameData.reset();
    
    // Recreate player and eagle if they exist
    try {
      player?.removeFromParent();
      eagle.removeFromParent();
    } catch (e) {
      // Components might not exist yet
    }
    
    player = Player(position: Vector2(330, 870));
    add(player!);

    eagle = Eagle(position: Vector2(420, 840));
    add(eagle);
    
    // Restart enemy spawning
    enemySpawnTimer?.timer.stop();
    _startEnemySpawning();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    final keyboard = HardwareKeyboard.instance;
    
    // Handle menu navigation
    if (showingMenu && mainMenu != null) {
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowUp)) {
        mainMenu!.navigateUp();
      }
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowDown)) {
        mainMenu!.navigateDown();
      }
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.space) ||
          keyboard.isLogicalKeyPressed(LogicalKeyboardKey.enter)) {
        mainMenu!.selectCurrentOption();
      }
      return;
    }
    
    // Handle other screen navigation
    if (multiplayerScreen != null || mapCreatorScreen != null) {
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.escape)) {
        showMainMenu();
      }
      return;
    }
    
    if (gameOver || victory) {
      // Handle restart key
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyR)) {
        _restartGame();
      }
      // Handle return to menu key
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.escape)) {
        showMainMenu();
      }
      return;
    }
    
    // Only handle player input if game is actually running and player exists
    if (!showingMenu && !gameOver && !victory && GameStateManager.currentState == GameState.singlePlayer) {
      // Handle player input using HardwareKeyboard
      bool isMoving = false;
      
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowUp) ||
          keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyW)) {
        player?.moveUp(dt);
        isMoving = true;
      }
      
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowDown) ||
          keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyS)) {
        player?.moveDown(dt);
        isMoving = true;
      }
      
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowLeft) ||
          keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyA)) {
        player?.moveLeft(dt);
        isMoving = true;
      }
      
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.arrowRight) ||
          keyboard.isLogicalKeyPressed(LogicalKeyboardKey.keyD)) {
        player?.moveRight(dt);
        isMoving = true;
      }
      
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.space)) {
        player?.fire();
      }
      
      // Handle return to menu key during gameplay
      if (keyboard.isLogicalKeyPressed(LogicalKeyboardKey.escape)) {
        showMainMenu();
      }
      
      player?.isMoving = isMoving;
    }
    
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
  
  // Menu navigation methods
  void startNewGame() async {
    GameStateManager.setState(GameState.singlePlayer);
    _hideCurrentScreen();
    showingMenu = false;
    await _initializeGame();
  }
  
  void showMultiplayer() {
    GameStateManager.setState(GameState.multiplayer);
    _hideCurrentScreen();
    multiplayerScreen = MultiplayerScreen();
    add(multiplayerScreen!);
    showingMenu = false;
  }
  
  void showMapCreator() {
    GameStateManager.setState(GameState.mapCreator);
    _hideCurrentScreen();
    mapCreatorScreen = MapCreatorScreen();
    add(mapCreatorScreen!);
    showingMenu = false;
  }
  
  void exitGame() {
    // Exit the game
    print('Exiting game');
  }
  
  void showMainMenu() {
    GameStateManager.setState(GameState.mainMenu);
    _hideCurrentScreen();
    showingMenu = true;
    gameOver = false;
    victory = false;
    
    // Show main menu
    mainMenu = MainMenu();
    add(mainMenu!);
  }
  
  void _hideCurrentScreen() {
    // Remove all screens
    if (victoryScreen != null) {
      victoryScreen!.removeFromParent();
      victoryScreen = null;
    }
    if (gameOverScreen != null) {
      gameOverScreen!.removeFromParent();
      gameOverScreen = null;
    }
    if (mainMenu != null) {
      mainMenu!.removeFromParent();
      mainMenu = null;
    }
    if (multiplayerScreen != null) {
      multiplayerScreen!.removeFromParent();
      multiplayerScreen = null;
    }
    if (mapCreatorScreen != null) {
      mapCreatorScreen!.removeFromParent();
      mapCreatorScreen = null;
    }
  }

  @override
  void onRemove() {
    enemySpawnTimer?.timer.stop();
    super.onRemove();
  }
}