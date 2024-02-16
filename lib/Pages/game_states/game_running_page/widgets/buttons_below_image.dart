import 'package:flutter/material.dart';
import 'package:mixup_app/Global/constants.dart';
import 'package:mixup_app/Global/player.dart';
import 'package:mixup_app/Pages/game_states/game_running_page/managers/local_manager.dart';
import 'package:mixup_app/Scanner/barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

final supabase = sb.Supabase.instance.client;

class ButtonsBelowImage extends StatefulWidget {
  const ButtonsBelowImage({super.key});

  @override
  State<ButtonsBelowImage> createState() => _ButtonsBelowImageState();
}

class _ButtonsBelowImageState extends State<ButtonsBelowImage> {
  @override
  Widget build(BuildContext context) {
    void handleItemScan(String scannedItem) {
      if (Player().heldItem != '') {
        return;
      } else {
        Provider.of<LocalManager>(context, listen: false)
            .changeHeldItem(scannedItem);
      }
    }

    /// Formats the name of the item to include the process. Sorts processes alphabetically if there's multiple.
    void handleProcessScan(String scannedProcess) {
      if (Player().heldItem == '') {
        return;
      }
      var splitItem = "${Player().heldItem}_$scannedProcess".split('_');
      final rawItem = splitItem[0];

      if (Constants.items[rawItem]![0] is Map) {
        var prerequisitesMap = Constants.items[rawItem]![0] as Map;
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

      if (!Player().heldItem.contains(scannedProcess) &&
          Constants.items[rawItem]!.contains(scannedProcess)) {
        Provider.of<LocalManager>(context, listen: false).changeHeldItem('');
        Provider.of<LocalManager>(context, listen: false)
            .changeProcessing(true);
        scannedProcess.toString();
        Provider.of<LocalManager>(context, listen: false)
            .changeProcessStatement(
                Constants.processStatements[scannedProcess] as String);
        Provider.of<LocalManager>(context, listen: false)
            .changeProcessTimer(Constants.processWait[scannedProcess] ?? 0);
        Provider.of<LocalManager>(context, listen: false)
            .changeSplitItem(splitItem);
        Provider.of<LocalManager>(context, listen: false)
            .changeRawItem(rawItem);
      }
    }

    void handlePlayerScan(int scannedPlayer) async {
      if (Player().heldItem != '') {
        return;
      }
      final itemList = await supabase
          .from('players')
          .select('held_item')
          .eq('playerNumber', scannedPlayer)
          .eq('lobby_id', Player().lobbyId)
          .single();
      if (context.mounted) {
        Provider.of<LocalManager>(context, listen: false)
            .changeHeldItem(itemList['held_item']);
      }
      await supabase
          .from('players')
          .update({'held_item': ''}).eq('playerNumber', scannedPlayer);
    }

    void handleScan(scan) {
      if (Constants.itemDeclaration.matchAsPrefix(scan) != null) {
        scan = scan.replaceAll(Constants.itemDeclaration, '');
        handleItemScan(scan);
      } else if (Constants.processDeclaration.matchAsPrefix(scan) != null) {
        scan = scan.replaceAll(Constants.processDeclaration, '');
        handleProcessScan(scan);
      } else if (Constants.playerDeclaration.matchAsPrefix(scan) != null) {
        scan = scan.replaceAll(Constants.playerDeclaration, '');
        handlePlayerScan(int.parse(scan));
      }
    }

    return SizedBox(
      height: 70,
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              onPressed: () async {
                String? scan = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (context) =>
                        const BarcodeScannerWithoutController(),
                  ),
                );
                if (scan != null) {
                  handleScan(scan);
                }
              },
              child: const Text('Scan')),
          ElevatedButton(
              onPressed: () {
                Provider.of<LocalManager>(context, listen: false)
                    .changeHeldItem('');
              },
              child: const Text('Discard Item'))
        ],
      ),
    );
  }
}
