import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../tank_game.dart';

class GameOverScreen extends Component with HasGameReference<TankGame> {
  late RectangleComponent background;
  late TextComponent titleText;
  late TextComponent instructionText;
  
  @override
  Future<void> onLoad() async {
    // Semi-transparent background
    background = RectangleComponent(
      size: Vector2(TankGame.gameWidth, TankGame.gameHeight),
      paint: Paint()..color = Colors.black.withOpacity(0.8),
    );
    add(background);
    
    // Game Over title
    titleText = TextComponent(
      text: 'GAME OVER',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(TankGame.gameWidth / 2, TankGame.gameHeight / 2 - 50),
    );
    add(titleText);
    
    // Instruction text
    instructionText = TextComponent(
      text: 'Press R to Restart or ESC to Exit',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(TankGame.gameWidth / 2, TankGame.gameHeight / 2 + 50),
    );
    add(instructionText);
  }
}