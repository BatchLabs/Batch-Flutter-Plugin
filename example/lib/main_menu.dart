import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'batch_store/root_tab_page.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
