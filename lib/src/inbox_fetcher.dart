import 'package:batch_flutter/batch_inbox.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Private class: Inbox fetcher base implementation
/// <nodoc>
@protected
abstract class BatchInboxFetcherBaseImpl extends BatchInboxFetcher {
  static const MethodChannel _channel =
      const MethodChannel('batch_flutter.inbox');

  bool _disposed = false;
  String? _fetcherID;

  Future<void> init();

  @override
  Future<List<BatchInboxNotificationContent>> get allNotifications async {
    _throwIfDisposed();

    Map<String, dynamic>? response = await _channel.invokeMapMethod(
        "inbox.getFetchedNotifications", _makeBaseBridgeParameters());

    if (response == null) {
      throw InboxInternalError(code: 3);
    }

    return _parseNotificationsFromResponse(response);
  }

  @override
  Future<BatchInboxFetchResult> fetchNewNotifications() async {
    _throwIfDisposed();

    Map<String, dynamic>? response = await _channel.invokeMapMethod(
        "inbox.fetchNewNotifications", _makeBaseBridgeParameters());

    if (response == null) {
      throw InboxInternalError(code: 3);
    }

    return BatchInboxFetchResult(
        notifications: _parseNotificationsFromResponse(response),
        endReached: response["endReached"] as bool);
  }

  @override
  Future<BatchInboxFetchResult> fetchNextPage() async {
    _throwIfDisposed();

    Map<String, dynamic>? response = await _channel.invokeMapMethod(
        "inbox.fetchNextPage", _makeBaseBridgeParameters());

    if (response == null) {
      throw InboxInternalError(code: 3);
    }

    return BatchInboxFetchResult(
        notifications: _parseNotificationsFromResponse(response),
        endReached: response["endReached"] as bool);
  }

  @override
  Future<void> markNotificationAsRead(
      BatchInboxNotificationContent notification) async {
    _throwIfDisposed();

    Map<String, dynamic> parameters = _makeBaseBridgeParameters();
    parameters["notifID"] = notification.id;
    await _channel.invokeMethod("inbox.markAsRead", parameters);
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    _throwIfDisposed();

    await _channel.invokeMethod(
        "inbox.markAllAsRead", _makeBaseBridgeParameters());
  }

  @override
  Future<void> markNotificationAsDeleted(
      BatchInboxNotificationContent notification) async {
    _throwIfDisposed();

    Map<String, dynamic> parameters = _makeBaseBridgeParameters();
    parameters["notifID"] = notification.id;
    await _channel.invokeMethod("inbox.markAsDeleted", parameters);
  }

  @override
  void dispose() {
    _disposed = true;
    if (_fetcherID != null) {
      _channel.invokeMethod(
          'inbox.releaseFetcher', _makeBaseBridgeParameters());
    }
  }

  void _throwIfDisposed() {
    if (_disposed) {
      throw DisposedInboxError();
    }
  }

  Map<String, dynamic> _makeBaseBridgeParameters() {
    if (_fetcherID == null) {
      throw InboxInternalError(code: 2);
    }
    return {"fetcherID": _fetcherID};
  }

  List<BatchInboxNotificationContent> _parseNotificationsFromResponse(
      Map<String, dynamic> response) {
    List<dynamic> rawNotifications = response["notifications"];

    List<BatchInboxNotificationContent> notifications = [];
    rawNotifications.forEach((rawNotification) {
      String id = rawNotification["id"] as String;
      String? title = rawNotification["title"] as String?;
      String body = rawNotification["body"] as String;
      bool isUnread = rawNotification["isUnread"] as bool;
      bool isDeleted = rawNotification["isDeleted"] as bool;
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(rawNotification["date"] as int)
              .toUtc();
      int rawSource = rawNotification["source"] as int;
      BatchInboxNotificationSource source =
          BatchInboxNotificationSource.unknown;
      switch (rawSource) {
        case 1:
          source = BatchInboxNotificationSource.campaign;
          break;
        case 2:
          source = BatchInboxNotificationSource.transactional;
          break;
        case 3:
          source = BatchInboxNotificationSource.trigger;
          break;
      }
      Map<String, String> payload = (rawNotification["payload"] as Map).cast();

      notifications.add(BatchInboxNotificationContent(
          id, title, body, isUnread, isDeleted, date, source, payload));
    });

    return notifications;
  }
}

/// Private class: Inbox fetcher implementation by installid
/// <nodoc>
@protected
class BatchInboxFetcherInstallationImpl extends BatchInboxFetcherBaseImpl {
  @override
  Future<void> init() async {
    String? fetcherID = await BatchInboxFetcherBaseImpl._channel
        .invokeMethod('inbox.createInstallationFetcher');
    if (fetcherID == null || fetcherID.isEmpty) {
      throw InboxInternalError(code: 0);
    }
    _fetcherID = fetcherID;
  }
}

/// Private class: Inbox fetcher implementation by custom id
/// <nodoc>
@protected
class BatchInboxFetcherUserImpl extends BatchInboxFetcherBaseImpl {
  BatchInboxFetcherUserImpl({required this.user, required this.authKey});

  final String user;
  final String authKey;

  @override
  Future<void> init() async {
    String? fetcherID = await BatchInboxFetcherBaseImpl._channel.invokeMethod(
        'inbox.createUserFetcher', {"user": user, "authKey": authKey});
    if (fetcherID == null || fetcherID.isEmpty) {
      throw InboxInternalError(code: 0);
    }
    _fetcherID = fetcherID;
  }
}
