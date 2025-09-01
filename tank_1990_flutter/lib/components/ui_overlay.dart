import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../tank_game.dart';
import '../game_data.dart';

class UIOverlay extends Component with HasGameReference<TankGame> {
  late TextComponent enemyCountText;
  late TextComponent levelText;
  
  @override
  Future<void> onLoad() async {
    // Enemy count display
    enemyCountText = TextComponent(
      text: 'Enemies: ${_getRemainingEnemies()}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 20),
    );
    add(enemyCountText);
    
    // Level display
    levelText = TextComponent(
      text: 'Level: ${_getCurrentLevel()}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(TankGame.gameWidth - 150, 20),
    );
    add(levelText);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update enemy count
    enemyCountText.text = 'Enemies: ${_getRemainingEnemies()}';
    levelText.text = 'Level: ${_getCurrentLevel()}';
  }
  
  int _getRemainingEnemies() {
    return (game.enemiesSpawned < GameData.enemiesToSpawn) 
        ? (GameData.enemiesToSpawn - game.enemiesSpawned + game.enemies.length)
        : game.enemies.length;
  }
  
  int _getCurrentLevel() {
    return 1; // For now, we'll use a static level
  }
}