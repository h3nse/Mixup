import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mixup_app/Global/items.dart';
import 'package:mixup_app/Scanner/barcode_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../../Global/player.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

final supabase = Supabase.instance.client;

class GameRunning extends StatefulWidget {
  final int lobbyID;
  final Function endFunction;
  const GameRunning(
      {super.key, required this.lobbyID, required this.endFunction});

  @override
  State<GameRunning> createState() => _GameRunningState();
}

class _GameRunningState extends State<GameRunning> {
  final int gameDurationMin = 5;
  String heldItem = '';
  String currentProcessingStatement = '';
  int processTimer = 0;
  final itemDeclaration = '<item>';
  final processDeclaration = '<process>';
  final playerDeclaration = '<player>';
  Map<String, String> processStatements = {
    'cut': 'Cutting',
    'fry': 'Frying',
    'boil': 'Boiling'
  };
  final processWait = {'cut': 3, 'fry': 6, 'boil': 10};
  // All items in the game, and which processes can be used on them.
  final items = {
    'Tomato': ['cut'],
    'Spaghetti': ['boil'],
    'Meat': ['cut', 'fry'],
    'Egg': [
      {
        'prerequisites': {
          'cut': ['boil'],
        },
        'negative prerequisites': {
          'fry': ['boil']
        }
      },
      'cut',
      'fry',
      'boil'
    ],
    'Cheese': [
      {
        'prerequisites': {
          'fry': ['cut']
        },
        'negative prerequisites': {}
      },
      'cut',
      'fry'
    ],
    'Salad': ['cut']
  }; // TODO Make class

  bool processing = false;

  @override
  void initState() {
    super.initState();
    supabase.channel('players').on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
            event: 'UPDATE',
            schema: 'public',
            table: 'players',
            filter: 'id=eq.${Player().id}'), (payload, [ref]) {
      setState(() {
        heldItem = payload['new']['held_item'];
      });
    }).subscribe();
  }

  void _setItem(String item) async {
    setState(() {
      heldItem = item;
    });
    await supabase
        .from('players')
        .update({'held_item': item}).eq('id', Player().id);
  }

  void _handleItemScan(String scannedItem) {
    if (heldItem != '') {
      return;
    } else {
      _setItem(scannedItem);
    }
  }

  void handleProcessTimeout(splitItem, rawItem) {
    splitItem.remove(rawItem);
    splitItem.sort((String a, String b) {
      return a.compareTo(b);
    });
    splitItem.insert(0, rawItem);
    _setItem(splitItem.join("_"));
    processing = false;
    setState(() {});
  }

  /// Formats the name of the item to include the process. Sorts processes alphabetically if there's multiple.
  void _handleProcessScan(String scannedProcess) {
    if (heldItem == '') {
      return;
    }
    var splitItem = "${heldItem}_$scannedProcess".split('_');
    final rawItem = splitItem[0];

    /// Prerequisite checks
    if (items[rawItem]![0] is Map) {
      var prerequisitesMap = items[rawItem]![0] as Map;
      var prerequisites = prerequisitesMap['prerequisites'][scannedProcess];
      if (prerequisites != null) {
        for (var prerequisite in prerequisites) {
          if (!splitItem.contains(prerequisite)) {
            return;
          }
        }
      }
      var negPrerequisites =
          prerequisitesMap['negative prerequisites'][scannedProcess];
      if (negPrerequisites != null) {
        for (var negPrerequisite in negPrerequisites) {
          if (splitItem.contains(negPrerequisite)) {
            return;
          }
        }
      }
    }

    if (!heldItem.contains(scannedProcess) &&

        ///TODO: include at beginning of function
        items[rawItem]!.contains(scannedProcess)) {
      _setItem('');
      setState(() {
        processing = true;
        scannedProcess.toString();
        currentProcessingStatement =
            processStatements[scannedProcess] as String;
        processTimer = processWait[scannedProcess] ?? 0;
      });
      Timer(Duration(seconds: processWait[scannedProcess] ?? 0),
          () => handleProcessTimeout(splitItem, rawItem));
    }
  }

  void _handlePlayerScan(int scannedPlayer) async {
    if (heldItem != '') {
      return;
    }
    final item = await supabase
        .from('players')
        .select('held_item')
        .eq('playerNumber', scannedPlayer)
        .eq('lobby_id', widget.lobbyID)
        .single();
    _setItem(item['held_item']);
    await supabase
        .from('players')
        .update({'held_item': ''}).eq('playerNumber', scannedPlayer);
  }

  void _handlePlateScan(int scannedPlate) async {
    final plateID = await supabase
        .from('plates')
        .select('id')
        .eq('lobby_id', widget.lobbyID)
        .eq('plate_nr', scannedPlate)
        .single();

    if (heldItem == '') {
      submitPlate(plateID['id']);
      return;
    }
    await supabase.from('_plates_items').insert({
      'plate_id': plateID['id'],
      'item_id': Items().getItemId(heldItem)
    }); // TODO Add catch if adding the same item to the same plate
    _setItem('');
  }

  void submitPlate(int plateID) async {
    await supabase.from('_plates_items').delete().eq('plate_id', plateID);
  }

  /// The data in the QR-codes start with a declaration <> of what type they are.
  void _handleScan(String scan) {
    final prefix = scan
        .split('>')[0]
        .replaceAll('<', ''); // TODO Change to: "declaration:value"
    scan = scan.split('>')[1];
    switch (prefix) {
      case 'item':
        _handleItemScan(scan);
      case 'process':
        _handleProcessScan(scan);
      case 'player':
        _handlePlayerScan(int.parse(scan));
      case 'plate':
        _handlePlateScan(int.parse(scan));
    }
  }

  /// Images are placed in /assets and are named after a naming convention.
  Image _getImageFromItem() {
    String imagePath = 'assets/$heldItem.jpg';
    if (heldItem == '') {
      imagePath = 'assets/No_item.jpg';
    }
    return Image.asset(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TimerCountdown(
            ///Fix so it stays loaded
            format: CountDownTimerFormat.minutesSeconds,
            enableDescriptions: false,
            spacerWidth: 5,
            timeTextStyle: const TextStyle(fontSize: 32),
            endTime: DateTime.now().add(
              Duration(minutes: gameDurationMin),
            ),
            onEnd: () {
              widget.endFunction();
            },
          ),
          const SizedBox(
            height: 250,
          ),
          SizedBox(
            height: 200,
            child: (!processing)
                ? _getImageFromItem()
                : Column(
                    children: [
                      Text("$currentProcessingStatement...",
                          style: const TextStyle(fontSize: 24)),
                      Countdown(
                        seconds: processTimer,
                        build: (BuildContext context, double time) => Text(
                          NumberFormat("0", "en_US").format(time).toString(),
                          style: const TextStyle(fontSize: 100),
                        ),
                      ),
                    ],
                  ),
          ),
          (!processing)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String? result =
                            await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (context) =>
                                const BarcodeScannerWithoutController(),
                          ),
                        );
                        if (result != null) {
                          _handleScan(result);
                        }
                      },
                      child: const Text("Scan"),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _setItem('');
                        },
                        child: const Text('Discard item'))
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
