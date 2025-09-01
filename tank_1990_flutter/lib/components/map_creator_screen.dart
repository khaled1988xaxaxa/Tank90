import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../tank_game.dart';

class MapCreatorScreen extends Component with HasGameReference<TankGame> {
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
      text: 'MAP CREATOR',
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
      text: 'Map editor functionality\ncoming soon!\n\nFeatures planned:\n• Drag and drop tiles\n• Save/Load custom maps\n• Test maps in-game',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(TankGame.gameWidth / 2, 400),
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