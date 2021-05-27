import 'package:batch_flutter/batch_inbox.dart';
import 'package:flutter/widgets.dart';

/// Private class: Inbox fetcher base implementation
/// <nodoc>
@protected
abstract class BatchInboxFetcherBaseImpl extends BatchInboxFetcher {
  Future<void> init();

  @override
  // TODO: implement allNotifications
  Future<List<BatchInboxNotificationContent>> get allNotifications =>
      throw UnimplementedError();

  @override
  Future<BatchInboxFetchResult> fetchNewNotifications() {
    // TODO: implement fetchNewNotifications
    throw UnimplementedError();
  }

  @override
  Future<BatchInboxFetchResult> fetchNextPage() {
    // TODO: implement fetchNextPage
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

/// Private class: Inbox fetcher implementation by installid
/// <nodoc>
@protected
class BatchInboxFetcherInstallationImpl extends BatchInboxFetcherBaseImpl {
  @override
  Future<void> init() async {
    return;
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
    return;
  }
}
