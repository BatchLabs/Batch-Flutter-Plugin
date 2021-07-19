import 'package:batch_flutter/batch_inbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef InboxMarkAsReadCallback = void Function();
typedef InboxDeleteCallback = void Function();

class InboxNotificationRowItem extends StatelessWidget {
  const InboxNotificationRowItem(
      {required this.notification,
      required this.onMarkAsRead,
      required this.onDelete});

  final BatchInboxNotificationContent notification;
  final InboxMarkAsReadCallback onMarkAsRead;
  final InboxDeleteCallback onDelete;

  static const int menuMarkAsReadItem = 1;
  static const int menuDeleteItem = 2;

  static const TextStyle _notificationTitleStyle =
      TextStyle(fontWeight: FontWeight.bold);

  List<PopupMenuEntry<Object>> makePopupMenu(BuildContext context) {
    var list = <PopupMenuEntry<Object>>[];
    if (notification.isUnread) {
      list.add(
        PopupMenuItem(
          child: Text("Mark as read"),
          value: menuMarkAsReadItem,
        ),
      );
    }
    list.add(
      PopupMenuItem(
        child: Text("Delete"),
        value: menuDeleteItem,
      ),
    );
    return list;
  }

  void performPopupMenuAction(Object value) {
    if (value == menuMarkAsReadItem) {
      onMarkAsRead();
    } else if (value == menuDeleteItem) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title ?? "",
                        style: _notificationTitleStyle,
                      ),
                    ),
                    if (notification.isUnread)
                      Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle)),
                  ],
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 6)),
                Text(notification.body),
              ],
            ),
          ),
          PopupMenuButton(
              itemBuilder: (context) {
                return makePopupMenu(context);
              },
              onSelected: performPopupMenuAction),
        ],
      ),
    );
  }
}
