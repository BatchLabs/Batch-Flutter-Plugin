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
    final eventData = BatchEventAttributes()
        .putObject(
          'delivery_address',
          BatchEventAttributes()
              .putInteger('number', 43)
              .putString('street', 'Rue Beaubourg')
              .putInteger('zip_code', 75003)
              .putString('city', 'Paris')
              .putString('country', 'France'),
        )
        .putInteger('number', 43)
        .putDate('date', DateTime.now())
        .putObjectList('items_list', [
          BatchEventAttributes()
              .putString('name', 'Basic Tee')
              .putString('size', 'M')
              .putDouble('price', 23.99)
              .putUrl(
                  'item_url', Uri.parse("https://batch-store.com/basic-tee"))
              .putUrl(
                  'item_image',
                  Uri.parse(
                      "https://batch-store.com/basic-tee/black/image.png"))
              .putBoolean('in_sales', true)
              .putObject(
                'level_2',
                BatchEventAttributes().putString('att_1', 'truc').putObject(
                      'level_3',
                      BatchEventAttributes().putString('att_2', 'machin'),
                    ),
              ),
          BatchEventAttributes()
              .putString('name', 'Short socks pack x3')
              .putString('size', '38-40')
              .putDouble('price', 15.99)
              .putUrl('item_url',
                  Uri.parse("https://batch-store.com/short-socks-pack-x3"))
              .putUrl(
                  'item_image',
                  Uri.parse(
                      "https://batch-store.com/short-socks-pack-x3/image.png"))
              .putBoolean('in_sales', false),
        ])
        .putStringList('metadata', ['first_purchase', 'apple_pay'])
        .putString('\$label', 'legacy_label')
        .putStringList('\$tags', ['first_purchase', 'in_promo']);
    BatchProfile.instance.trackEvent(name: "test_event", attributes: eventData);
    BatchProfile.instance.trackLocation(latitude: 0.4, longitude: 0.523232);
  }

  void testCustomData() {
    BatchProfileAttributeEditor editor = BatchProfile.instance.newEditor();
    editor
        .setEmailAddress("john.doe@batch.com")
        .setEmailMarketingSubscription(BatchEmailSubscriptionState.subscribed)
        .setPhoneNumber("+33682449977")
        .setSMSMarketingSubscription(BatchSMSSubscriptionState.subscribed)
        .setBooleanAttribute("boolean", true)
        .setStringAttribute("string", "bar")
        .setDateTimeAttribute("date", DateTime.now())
        .setIntegerAttribute("int", 1)
        .setDoubleAttribute("double", 2.3)
        .setUrlAttribute("url", Uri.parse("https://batch.com/about"))
        .setStringListAttribute("os", ["windows", "linux"])
        .addToArray("push_optin", "foot")
        .addToArray("os", "macos")
        .addToArray("push_optin", "rugby")
        .removeFromArray("push_optin", "handball")
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
    BatchProfile.instance.newEditor()
        .setEmailAddress(null)
        .setPhoneNumber(null)
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
              child: Text("Request notif. auth."),
              onPressed: () =>
                  BatchPush.instance.requestNotificationAuthorization(),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    onChanged: (text) {
                      _customID = text;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Identifier or empty to logout',
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Text("Identify"),
                  onPressed: () => {
                    _customID.isEmpty
                        ? BatchProfile.instance.identify(null)
                        : BatchProfile.instance.identify(_customID)
                  },
                ),
              ],
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
            Row(
              children: [
                ElevatedButton(
                  child: Text("Notif On"),
                  onPressed: () =>
                  {BatchPush.instance.setShowNotifications(true)},
                ),
                ElevatedButton(
                  child: Text("Notif Off"),
                  onPressed: () =>
                  {BatchPush.instance.setShowNotifications(false)},
                ),
                ElevatedButton(
                  child: Text("Show Pending"),
                  onPressed: () async => {print(await BatchPush.instance.shouldShowNotifications())},
                ),
              ],
            ),
            ElevatedButton(
              child: Text("Is Opted-Out"),
              onPressed: () async => {print(await Batch.instance.isOptedOut())},
            ),
            ElevatedButton(
                child: Text("Test inbox"), onPressed: () => testInbox()),
          ],
        ));
  }
}
