import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../tank_game.dart';

class MainMenu extends Component with HasGameReference<TankGame> {
  late RectangleComponent background;
  late TextComponent titleText;
  late List<MenuButton> menuButtons;
  int selectedIndex = 0;
  
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
      text: 'TANK 1990',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 64,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(TankGame.gameWidth / 2, 150),
    );
    add(titleText);
    
    // Menu buttons
    menuButtons = [
      MenuButton(
        text: 'NEW GAME',
        position: Vector2(TankGame.gameWidth / 2, 300),
        onPressed: () => game.startNewGame(),
      ),
      MenuButton(
        text: 'MULTIPLAYER',
        position: Vector2(TankGame.gameWidth / 2, 400),
        onPressed: () => game.showMultiplayer(),
      ),
      MenuButton(
        text: 'CREATE MAP',
        position: Vector2(TankGame.gameWidth / 2, 500),
        onPressed: () => game.showMapCreator(),
      ),
      MenuButton(
        text: 'EXIT',
        position: Vector2(TankGame.gameWidth / 2, 600),
        onPressed: () => game.exitGame(),
      ),
    ];
    
    for (int i = 0; i < menuButtons.length; i++) {
      menuButtons[i].isSelected = (i == selectedIndex);
      add(menuButtons[i]);
    }
    
    // Instructions
    final instructionText = TextComponent(
      text: 'Use ARROW KEYS to navigate, SPACE to select',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(TankGame.gameWidth / 2, TankGame.gameHeight - 50),
    );
    add(instructionText);
  }
  
  void navigateUp() {
    if (selectedIndex > 0) {
      menuButtons[selectedIndex].isSelected = false;
      selectedIndex--;
      menuButtons[selectedIndex].isSelected = true;
    }
  }
  
  void navigateDown() {
    if (selectedIndex < menuButtons.length - 1) {
      menuButtons[selectedIndex].isSelected = false;
      selectedIndex++;
      menuButtons[selectedIndex].isSelected = true;
    }
  }
  
  void selectCurrentOption() {
    menuButtons[selectedIndex].onPressed();
  }
}

class MenuButton extends Component {
  final String text;
  final Vector2 position;
  final VoidCallback onPressed;
  bool _isSelected = false;
  
  late TextComponent textComponent;
  late RectangleComponent backgroundRect;
  
  MenuButton({
    required this.text,
    required this.position,
    required this.onPressed,
  });
  
  bool get isSelected => _isSelected;
  
  set isSelected(bool value) {
    _isSelected = value;
    if (isMounted && hasChildren) {
      _updateAppearance();
    }
  }
  
  @override
  Future<void> onLoad() async {
    // Background rectangle
    backgroundRect = RectangleComponent(
      size: Vector2(300, 60),
      paint: Paint()..color = Colors.grey.withOpacity(0.3),
      anchor: Anchor.center,
      position: position,
    );
    add(backgroundRect);
    
    // Text
    textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: position,
    );
    add(textComponent);
    
    _updateAppearance();
  }
  
  void _updateAppearance() {
    if (isMounted && hasChildren) {
      if (_isSelected) {
        textComponent.textRenderer = TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        );
        backgroundRect.paint = Paint()..color = Colors.yellow.withOpacity(0.2);
      } else {
        textComponent.textRenderer = TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        );
        backgroundRect.paint = Paint()..color = Colors.grey.withOpacity(0.3);
      }
    }
  }
}