import 'package:batch_flutter/batch.dart';
import 'package:batch_flutter_example/plugin_test_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        makeListSeparator(context, "Notifications"),
        SwitchListTile(
          title: Text('Flash sales'),
          value: true,
          onChanged: (value) => {
            // TODO Implement
          },
        ),
        makeListSeparator(context, "Suggestion topics"),
        SwitchListTile(
          title: Text('Suggested content'),
          value: true,
          onChanged: (value) => {
            // TODO Implement
          },
        ),
        SwitchListTile(
          title: Text('  Fashion'),
          value: true,
          onChanged: (value) => {
            // TODO Implement
          },
        ),
        SwitchListTile(
          title: Text("  Men's wear"),
          value: true,
          onChanged: (value) => {
            // TODO Implement
          },
        ),
        SwitchListTile(
          title: Text('  Other'),
          value: true,
          onChanged: (value) => {
            // TODO Implement
          },
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
      ],
    );
  }

  Widget makeListSeparator(BuildContext context, String text) {
    return Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 20, 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.subtitle2,
        ));
  }

  void _openPluginTests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PluginTestMenu()),
    );
  }
}
