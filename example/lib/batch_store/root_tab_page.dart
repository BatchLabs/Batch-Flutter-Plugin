import 'package:batch_flutter_example/batch_store/ui/cart/cart_tab.dart';
import 'package:batch_flutter_example/batch_store/ui/inbox/inbox_tab.dart';
import 'package:batch_flutter_example/batch_store/ui/settings/settings_tab.dart';
import 'package:batch_flutter_example/batch_store/ui/shop/shop_tab.dart';
import 'package:flutter/material.dart';

class RootTabPage extends StatefulWidget {
  RootTabPage({Key? key}) : super(key: key);

  @override
  _RootTabPageState createState() => _RootTabPageState();
}

class _RootTabPageState extends State<RootTabPage> {
  int _selectedTabIndex = 0;

  void _onTabItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  final List<Widget> _tabWidgets = <Widget>[
    ShopTab(),
    CartTab(),
    InboxTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(title: Text("Batch Store")),
        body: _tabWidgets[_selectedTabIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag), label: "Shop"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Cart"),
            BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Inbox"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedTabIndex,
          onTap: _onTabItemTapped,
        ),
      ),
    );
  }
}
