import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../tank_game.dart';

class MultiplayerScreen extends Component with HasGameReference<TankGame> {
  late RectangleComponent background;
  late TextComponent titleText;
  late TextComponent messageText;
  late TextComponent instructionText;
  
  @override
  Future<void> onLoad() async {
    // Background
    background = RectangleComponent(
      size: Vector2(TankGame.gameWidth, TankGame.gameHeight),
      paint: Paint()..color = Colors.black.withOpacity(0.9),
    );
    add(background);
    
    // Title
    titleText = TextComponent(
      text: 'MULTIPLAYER MODE',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(TankGame.gameWidth / 2, 200),
    );
    add(titleText);
    
    // Message
    messageText = TextComponent(
      text: 'Multiplayer functionality\ncoming soon!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(TankGame.gameWidth / 2, 350),
    );
    add(messageText);
    
    // Instructions
    instructionText = TextComponent(
      text: 'Press ESC to return to main menu',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 20,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(TankGame.gameWidth / 2, TankGame.gameHeight - 100),
    );
    add(instructionText);
  }
}