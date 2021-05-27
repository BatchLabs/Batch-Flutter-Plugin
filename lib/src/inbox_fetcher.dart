import 'package:batch_flutter/batch_inbox.dart';
import 'package:flutter/widgets.dart';

/// Private class: Inbox fetcher base implementation
/// <nodoc>
@protected
class BatchInboxFetcherBaseImpl extends BatchInboxFetcher {
  Future<void> init() async {
    return;
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
