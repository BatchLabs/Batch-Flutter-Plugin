import 'package:batch_flutter/batch.dart';
import 'package:batch_flutter_example/batch_store/data/model/subscriptions.dart';
import 'package:batch_flutter_example/data_collection_settings.dart';
import 'package:batch_flutter_example/plugin_test_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionsModel>(
        builder: (context, subscriptions, child) {
      return ListView(
        children: [
          makeListSeparator(context, "Notifications"),
          SwitchListTile(
            title: Text('Flash sales'),
            value: subscriptions.subscribedToFlashSales,
            onChanged: (value) =>
                {subscriptions.subscribedToFlashSales = value},
          ),
          makeListSeparator(context, "Suggestion topics"),
          SwitchListTile(
            title: Text('Suggested content'),
            value: subscriptions.subscribedToSuggestedContent,
            onChanged: (value) =>
                {subscriptions.subscribedToSuggestedContent = value},
          ),
          SwitchListTile(
            title: Text('  Fashion'),
            value: subscriptions.subscribedToFashionSuggestions,
            onChanged: (value) =>
                {subscriptions.subscribedToFashionSuggestions = value},
          ),
          SwitchListTile(
            title: Text('  Other'),
            value: subscriptions.subscribedToOtherSuggestions,
            onChanged: (value) =>
                {subscriptions.subscribedToOtherSuggestions = value},
          ),
          makeListSeparator(context, "Advanced"),
          ListTile(
            title: Text('Batch Debug'),
            onTap: () => {Batch.instance.showDebugView()},
          ),
          ListTile(
            title: Text('Flutter plugin tests'),
            onTap: () => {_openPluginTests(context)},
          ),
          ListTile(
            title: Text('Data Collection Settings'),
            onTap: () => {_openDataCollectionSettings(context)},
          ),
        ],
      );
    });
  }

  Widget makeListSeparator(BuildContext context, String text) {
    return Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 20, 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall,
        ));
  }

  void _openDataCollectionSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataCollectionSettings()),
    );
  }

  void _openPluginTests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PluginTestMenu()),
    );
  }
}
