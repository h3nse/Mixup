import 'package:flutter/material.dart';
import 'package:mixup_app/Global/constants.dart';
import 'package:mixup_app/Pages/lobby_select_page.dart';
import 'package:mixup_app/Scanner/barcode_scanner.dart';
import 'package:mixup_app/Global/player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  final nameController = TextEditingController();
  bool validPlayerRegistration = false;

  void addPlayer() async {
    await supabase.from('players').insert({
      'player_name': Player().name,
      'id': Player().id,
      'playerNumber': Player().playerNumber
    });
  }

  void handlePlayerScan(scan) {
    if (Constants.playerDeclaration.matchAsPrefix(scan) == null) {
      return;
    }
    scan = scan.replaceAll(Constants.playerDeclaration, '');
    final playerNumber = int.parse(scan);
    setState(() {
      Player().playerNumber = playerNumber;
      validPlayerRegistration = true;
    });
  }

  // Remove from memory(?) when route changes
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Mixup"),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: ("Enter your username"),
            ),
          ),
          (validPlayerRegistration)
              ? Text("Player Number: ${Player().playerNumber.toString()}")
              : Container(),
          ElevatedButton(
              onPressed: () async {
                String? result = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (context) =>
                        const BarcodeScannerWithoutController(),
                  ),
                );
                if (result != null) {
                  handlePlayerScan(result);
                }
              },
              child: const Text("Register player number")),
          (validPlayerRegistration)
              ? ElevatedButton(
                  onPressed: () {
                    if (nameController.text == "") {
                      Player().name = "Unnamed";
                    } else {
                      Player().name = nameController.text;
                    }
                    addPlayer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LobbySelectPage()));
                  },
                  child: const Text("Play"),
                )
              : Container(),
        ],
      ),
    );
  }
}
