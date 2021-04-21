import 'package:batch_flutter/batch_push.dart';
import 'package:batch_flutter/batch_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'batch_store/root_tab_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String _installationID = 'Unknown';
  String _lastPushToken = 'Unknown';

  @override
  void initState() {
    super.initState();
    updateBatchInformation();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> updateBatchInformation() async {
    String installationID;
    String lastPushToken;

    try {
      installationID =
          await BatchUser.instance.installationID ?? 'null Installation ID';
    } on PlatformException {
      installationID = 'Failed to get Installation ID.';
    }

    try {
      lastPushToken =
          await BatchPush.instance.lastKnownPushToken ?? 'null Installation ID';
    } on PlatformException {
      lastPushToken = 'Failed to get Installation ID.';
    }

    if (!mounted) return;

    setState(() {
      _installationID = installationID;
      _lastPushToken = lastPushToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Installation ID: $_installationID"),
        Text("Last Push Token: $_lastPushToken"),
        ElevatedButton(
          child: Text("Refresh"),
          onPressed: () => updateBatchInformation(),
        ),
        ElevatedButton(
          child: Text("Open Batch Store"),
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RootTabPage()),
            )
          },
        ),
      ],
    );
  }
}
