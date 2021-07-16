import 'package:batch_flutter/batch_push.dart';
import 'package:batch_flutter_example/batch_store/root_tab_page.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'batch_store/data/model/app_state_model.dart';
import 'batch_store/data/model/cart.dart';
import 'plugin_test_menu.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<BatchStoreAppStateModel>(
        create: (_) => BatchStoreAppStateModel()..loadModel(),
      ),
      ChangeNotifierProvider<CartModel>(
        create: (_) => CartModel()..loadModel(),
      )
    ],
    child: BatchExampleApp(),
  ));
}

class BatchExampleApp extends StatefulWidget {
  @override
  _BatchExampleAppState createState() => _BatchExampleAppState();
}

class _BatchExampleAppState extends State<BatchExampleApp> {
  @override
  void initState() {
    super.initState();
    BatchPush.instance.setShowForegroundNotificationsOniOS(true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RootTabPage(),
    );
  }
}
