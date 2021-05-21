import 'package:batch_flutter/batch.dart';
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
          await BatchPush.instance.lastKnownPushToken ?? 'null push token';
    } on PlatformException {
      lastPushToken = 'Failed to get Push Token';
    }

    if (!mounted) return;

    setState(() {
      _installationID = installationID;
      _lastPushToken = lastPushToken;
    });
  }

  void testCustomEvent() {
    BatchEventData eventData = new BatchEventData();
    eventData.putString("string", "bar");
    eventData.putBoolean("bool", true);
    eventData.putDate("date", DateTime.now());
    eventData.putInteger("int", 1);
    eventData.putDouble("double", 2.3);
    eventData.addTag("tag1");
    eventData.addTag("tag1").addTag("tag2");
    BatchUser.instance
        .trackEvent(name: "test_event", label: "test_label", data: eventData);

    BatchUser.instance.trackLocation(latitude: 0.4, longitude: 0.523232);
    BatchUser.instance.trackTransaction(0.34);
  }

  void testCustomData() {
    BatchUserDataEditor editor = BatchUser.instance.newEditor();
    editor
        .setIdentifier("test_user")
        .setBooleanAttribute("bootl", true)
        .setStringAttribute("string", "bar")
        .setDateTimeAttribute("date", DateTime.now())
        .setIntegerAttribute("int", 1)
        .setDoubleAttribute("double", 2.3)
        .addTag("push_optin", "foot")
        .addTag("push_optin", "rugby")
        .setLanguage("pt")
        .setRegion("BR")
        .save();
  }

  void testReadCustomData() async {
    var tags = await BatchUser.instance.tagCollections;
    print("Tags: " + tags.toString());
  }

  void resetCustomData() {
    BatchUser.instance
        .newEditor()
        .setIdentifier(null)
        .setLanguage(null)
        .setRegion(null)
        .clearAttributes()
        .clearTagCollection("foobar")
        .clearTags()
        .save();
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
          child: Text("Request notif. auth. (iOS)"),
          onPressed: () =>
              BatchPush.instance.requestNotificationAuthorization(),
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
        ElevatedButton(
          child: Text("Open Batch Debug"),
          onPressed: () => {Batch.instance.showDebugView()},
        ),
        ElevatedButton(
          child: Text("Test custom event"),
          onPressed: () => {testCustomEvent()},
        ),
        ElevatedButton(
          child: Text("Test custom data"),
          onPressed: () => {testCustomData()},
        ),
        ElevatedButton(
          child: Text("Test read custom data"),
          onPressed: () => {testReadCustomData()},
        ),
        ElevatedButton(
          child: Text("Reset custom data"),
          onPressed: () => {resetCustomData()},
        ),
        ElevatedButton(
          child: Text("Opt-in"),
          onPressed: () => {Batch.instance.optIn()},
        ),
        ElevatedButton(
          child: Text("Opt-out"),
          onPressed: () async => {await Batch.instance.optOut()},
        ),
        ElevatedButton(
          child: Text("Opt-out and wipe data"),
          onPressed: () => {Batch.instance.optOutAndWipeData()},
        ),
      ],
    );
  }
}
