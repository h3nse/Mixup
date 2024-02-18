import 'package:mixup_app/Global/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

int convertStringToNumbers(String string) {
  String numberString = '';
  for (int i = 0; i < string.length; i++) {
    numberString = [numberString, string.codeUnitAt(i).toString()].join();
  }
  return int.parse(numberString);
}

final supabase = Supabase.instance.client;

void changeGameState(String gameState) async {
  await supabase
      .from('lobbies')
      .update({'game_state': gameState}).eq('id', Player().lobbyId);
}
