/// Singleton for storing local information about the player.
class Player {
  static final Player _instance = Player._internal(0, "", 0, '', 0, false);
  int id;
  String name;
  int lobbyId;
  String heldItem;
  int playerNumber;
  bool isHost;

  factory Player() {
    return _instance;
  }

  Player._internal(this.id, this.name, this.lobbyId, this.heldItem,
      this.playerNumber, this.isHost);
}
