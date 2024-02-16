import 'package:flutter/material.dart';
import 'package:mixup_app/Global/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LocalManager extends ChangeNotifier {
  String _heldItem = '';
  List<String> _splitItem = [];
  String _rawItem = '';
  bool _processing = false;
  String _processingStatement = '';
  int _processTimer = 0;

  String get heldItem => _heldItem;
  List<String> get splitItem => _splitItem;
  String get rawitem => _rawItem;
  bool get processing => _processing;
  String get processStatement => _processingStatement;
  int get processTimer => _processTimer;

  void changeHeldItem(String item) async {
    _heldItem = item;
    Player().heldItem = item;
    await supabase
        .from('players')
        .update({'held_item': item}).eq('id', Player().id);
    notifyListeners();
  }

  void changeSplitItem(List<String> items) {
    _splitItem = items;
    notifyListeners();
  }

  void changeRawItem(String item) {
    _rawItem = item;
    notifyListeners();
  }

  void changeProcessing(bool value) {
    _processing = value;
    notifyListeners();
  }

  void changeProcessStatement(String statement) {
    _processingStatement = statement;
    notifyListeners();
  }

  void changeProcessTimer(int time) {
    _processTimer = time;
    notifyListeners();
  }
}
