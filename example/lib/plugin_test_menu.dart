import 'package:batch_flutter/batch.dart';
import 'package:batch_flutter/batch_push.dart';
import 'package:batch_flutter/batch_inbox.dart';
import 'package:batch_flutter/batch_messaging.dart';
import 'package:batch_flutter/batch_user.dart';
import 'package:batch_flutter/batch_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PluginTestMenu extends StatefulWidget {
  const PluginTestMenu({Key? key}) : super(key: key);

  @override
  _PluginTestMenuState createState() => _PluginTestMenuState();
}

class _PluginTestMenuState extends State<PluginTestMenu> {
  String _installationID = 'Unknown';
  String _lastPushToken = 'Unknown';
  String _languageRegion = 'Language override: Unknown, Region: Unknown';
  String _customID = 'Unknown';

  @override
  void initState() {
    super.initState();
    updateBatchInformation();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> updateBatchInformation() async {
    String installationID;
    String lastPushToken;
    String languageRegion;
    String customID;

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

    try {
      customID = await BatchUser.instance.identifier ?? 'null Custom ID';
    } on PlatformException {
      customID = 'Failed to get Custom ID.';
    }

    try {
      var language = await BatchUser.instance.language ?? 'none';
      var region = await BatchUser.instance.region ?? 'none';
      languageRegion = 'Language override: $language, Region: $region';
    } on PlatformException {
      languageRegion = 'Failed to get custom language/region.';
    }

    if (!mounted) return;

    setState(() {
      _installationID = installationID;
      _lastPushToken = lastPushToken;
      _languageRegion = languageRegion;
      _customID = customID;
    });
  }

  void testCustomEvent() {
    BatchEventData eventData = new BatchEventData();
    eventData.putString("string", "bar");
    eventData.putBoolean("bool", true);
    eventData.putDate("date", DateTime.now());
    eventData.putInteger("int", 1);
    eventData.putDouble("double", 2.3);
    eventData.putUrl("url", Uri.parse("https://batch.com/about"));
    eventData.putObject("myObj", eventData);
    eventData.putObjectList("obj_list", [eventData, new BatchEventData().putString("obj_list_item2", "value")]);
    eventData.putString("\$label", "test_label");
    eventData.putStringList("\$tags", ["tag1", "tag2"]);
    BatchProfile.instance.trackEvent(name: "test_event", data: eventData);
    BatchProfile.instance.trackLocation(latitude: 0.4, longitude: 0.523232);
  }

  void testCustomData() {
    BatchProfileAttributeEditor editor = BatchProfile.instance.newEditor();
    editor
        .setEmailAddress("john.doe@batch.com")
        .setEmailMarketingSubscription(BatchEmailSubscriptionState.subscribed)
        .setBooleanAttribute("bootl", true)
        .setStringAttribute("string", "bar")
        .setDateTimeAttribute("date", DateTime.now())
        .setIntegerAttribute("int", 1)
        .setDoubleAttribute("double", 2.3)
        .setUrlAttribute("url", Uri.parse("https://batch.com/about"))
        .setStringListAttribute("mylist", ["michel", "c'est le bresil"])
        .addToArray("push_optin", "foot")
        .addToArray("mylist", "foot")
        .addToArray("push_optin", "rugby")
        .removeFromArray("push_optin", "coco")
        .setLanguage("pt")
        .setRegion("BR")
        .save();
  }

  void testReadCustomData() async {
    var tags = await BatchUser.instance.tagCollections;
    print("Tags: " + tags.toString());
    var attributes = await BatchUser.instance.attributes;
    print("Attributes: " + attributes.toString());
  }

  void resetCustomData() {
    BatchProfile.instance
        .newEditor()
        .setLanguage(null)
        .setRegion(null)
        .save();
    BatchUser.instance.clearInstallationData();
  }

  void testInbox() async {
    var fetcher = await BatchInbox.instance.getFetcherForInstallation();
    var notifs = await fetcher.fetchNewNotifications();
    var notif = notifs.notifications.first;
    fetcher.markNotificationAsRead(notif);
    fetcher.markNotificationAsDeleted(notif);
    fetcher.markAllNotificationsAsRead();
    fetcher.dispose();
    print(notifs.notifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Plugin Tests"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Installation ID: $_installationID"),
            Text("Last Push Token: $_lastPushToken"),
            Text("Custom ID: $_customID"),
            Text("$_languageRegion"),
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
              child: Text("Open Batch Debug"),
              onPressed: () => {Batch.instance.showDebugView()},
            ),
            Row(children: [
              ElevatedButton(
                child: Text("Test custom event"),
                onPressed: () => {testCustomEvent()},
              ),
              ElevatedButton(
                child: Text("Test custom data"),
                onPressed: () => {testCustomData()},
              ),
            ]),
            Row(children: [
              ElevatedButton(
                child: Text("Test read custom data"),
                onPressed: () => {testReadCustomData()},
              ),
              ElevatedButton(
                child: Text("Reset custom data"),
                onPressed: () => {resetCustomData()},
              ),
            ]),
            Row(
              children: [
                ElevatedButton(
                  child: Text("DnD On"),
                  onPressed: () =>
                      {BatchMessaging.instance.setDoNotDisturbEnabled(true)},
                ),
                ElevatedButton(
                  child: Text("DnD Off"),
                  onPressed: () =>
                      {BatchMessaging.instance.setDoNotDisturbEnabled(false)},
                ),
                ElevatedButton(
                  child: Text("Show Pending"),
                  onPressed: () =>
                      {BatchMessaging.instance.showPendingMessage()},
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  child: Text("Opt-in"),
                  onPressed: () => {Batch.instance.optIn()},
                ),
                ElevatedButton(
                  child: Text("Opt-out"),
                  onPressed: () async => {await Batch.instance.optOut()},
                ),
                ElevatedButton(
                  child: Text("Opt-out wipe"),
                  onPressed: () => {Batch.instance.optOutAndWipeData()},
                ),
              ],
            ),
            ElevatedButton(
              child: Text("Is Opted-Out"),
              onPressed: () async => {
                print(await Batch.instance.isOptedOut())
              },
            ),
            ElevatedButton(
                child: Text("Test inbox"), onPressed: () => testInbox()),
          ],
        ));
  }
}
