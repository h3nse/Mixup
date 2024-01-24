/// Singleton for storing local information about the player. Name could be removed in future passes.
class Player {
  static final Player _instance = Player._internal("", 0, 0);
  String name;
  int id;
  int playerNumber;

  factory Player() {
    return _instance;
  }

  Player._internal(this.name, this.id, this.playerNumber);
}
