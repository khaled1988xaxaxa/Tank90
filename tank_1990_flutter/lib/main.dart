import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'tank_game.dart';

void main() {
  runApp(const TankGameApp());
}

class TankGameApp extends StatelessWidget {
  const TankGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tank 1990 - Battle City',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late TankGame game;

  @override
  void initState() {
    super.initState();
    game = TankGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.0, // Square aspect ratio for the game
            child: GameWidget<TankGame>.controlled(
              gameFactory: () => game,
            ),
          ),
        ),
      ),
    );
  }
}
