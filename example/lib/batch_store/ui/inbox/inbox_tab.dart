import 'package:batch_flutter/batch_inbox.dart';
import 'package:batch_flutter_example/batch_store/ui/inbox/inbox_notification_row_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InboxTab extends StatefulWidget {
  @override
  _InboxTabState createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  BatchInboxFetcher? fetcher;

  List<BatchInboxNotificationContent> notifications = [];

  @override
  void initState() {
    super.initState();

    // Show the refresh indicator on initial load
    WidgetsBinding.instance?.addPostFrameCallback((Duration duration) {
      this._refreshIndicatorKey.currentState?.show();
    });

    setupFetcher();
  }

  void setupFetcher() async {
    fetcher = await BatchInbox.instance
        .getFetcherForInstallation(maxPageSize: 20, limit: 2000);
    _refresh();
  }

  // Refresh notifications from the server
  Future _refresh() async {
    BatchInboxFetcher? localFetcher = fetcher;
    if (localFetcher != null) {
      BatchInboxFetchResult result = await localFetcher.fetchNewNotifications();
      setState(() {
        notifications = result.notifications;
      });
    }
  }

  // Simple refresh that doesn't call the server
  // Useful when changing state (read, deleted)
  Future _fastRefresh() async {
    BatchInboxFetcher? localFetcher = fetcher;
    if (localFetcher != null) {
      List<BatchInboxNotificationContent> newNotifications =
          await localFetcher.allNotifications;
      setState(() {
        notifications = newNotifications;
      });
    }
  }

  void _markAsRead(BatchInboxNotificationContent notification) {
    fetcher?.markNotificationAsRead(notification);
    _fastRefresh();
  }

  void _markAllAsRead() {
    fetcher?.markAllNotificationsAsRead();
    _fastRefresh();
  }

  void _delete(BatchInboxNotificationContent notification) {
    fetcher?.markNotificationAsDeleted(notification);
    _fastRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    fetcher?.dispose();
    fetcher = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => Divider(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  BatchInboxNotificationContent notification =
                      notifications[index];
                  return InboxNotificationRowItem(
                      notification: notification,
                      onMarkAsRead: () {
                        _markAsRead(notification);
                      },
                      onDelete: () {
                        _delete(notification);
                      });
                },
              ),
              onRefresh: _refresh),
        ),
        TextButton(
          onPressed: _markAllAsRead,
          child: Row(
            // Replace with a Row for horizontal icon + text
            children: [
              const Icon(Icons.mark_email_read),
              Padding(padding: const EdgeInsets.all(5)),
              Text("Mark all as read")
            ],
          ),
        ),
      ],
    );
  }
}
