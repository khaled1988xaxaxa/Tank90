enum GameState {
  mainMenu,
  singlePlayer,
  multiplayer,
  mapCreator,
  gameOver,
  victory,
  paused,
}

class GameStateManager {
  static GameState _currentState = GameState.mainMenu;
  static GameState? _previousState;
  
  static GameState get currentState => _currentState;
  static GameState? get previousState => _previousState;
  
  static void setState(GameState newState) {
    _previousState = _currentState;
    _currentState = newState;
  }
  
  static void goBack() {
    if (_previousState != null) {
      final temp = _currentState;
      _currentState = _previousState!;
      _previousState = temp;
    }
  }
  
  static bool isInGame() {
    return _currentState == GameState.singlePlayer || 
           _currentState == GameState.multiplayer;
  }
  
  static bool isInMenu() {
    return _currentState == GameState.mainMenu;
  }
  
  static void reset() {
    _currentState = GameState.mainMenu;
    _previousState = null;
  }
}