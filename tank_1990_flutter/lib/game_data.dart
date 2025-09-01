class GameData {
  static int enemiesToSpawn = 9;
  static int enemiesAlive = enemiesToSpawn;
  static int playerLives = 1;
  static int round = 1;
  
  static void reset() {
    enemiesAlive = enemiesToSpawn;
    playerLives = 1;
    round = 1;
  }
  
  static void nextRound() {
    round++;
    enemiesAlive = enemiesToSpawn;
  }
}