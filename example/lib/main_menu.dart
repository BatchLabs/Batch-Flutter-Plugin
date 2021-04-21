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

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String installationID;
    try {
      installationID =
          await BatchUser.instance.installationID ?? 'null Installation ID';
    } on PlatformException {
      installationID = 'Failed to get Installation ID.';
    }

    if (!mounted) return;

    setState(() {
      _installationID = installationID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Installation ID: $_installationID"),
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
