/// Batch Inbox module
class BatchInbox {
  /// Batch Inbox module singleton.
  static BatchInbox instance = new BatchInbox();

  /// Get an inbox fetcher for the current installation ID.
  Future<BatchInboxFetcher> getFetcherForInstallation() async {
    //TODO Implement inbox fetcher
    throw "Not implemented";
  }

  /// Get an inbox fetcher for a user identifier.
  ///
  /// Set [userIdentifier] to the identifier for which you want the notifications:
  /// this is usually the current user's identifier, set in `BatchUser`.
  ///
  /// The [authenticationKey] is the secret used to authenticate the request.
  /// It should be computed by your backend. See the documentation for more info
  /// on how to generate it.
  Future<BatchInboxFetcher> getFetcherForUser(
      {required String userIdentifier,
      required String authenticationKey}) async {
    //TODO Implement inbox fetcher
    throw "Not implemented";
  }
}

/// BatchInboxFetcher allows you to fetch notifications that have been sent to a
/// user (or installation, more on that later) in their raw form, allowing you
/// to display them in a list, for example.
/// This is also useful to display messages to users who disabled notifications.
///
/// Once you get your BatchInboxFetcher instance, you should call
/// [fetchNewNotifications] to fetch the initial page of messages:
/// nothing is done automatically.
/// This method is also useful to refresh the list from the beginning, like in a
/// "pull to refresh" scenario.
///
/// In an effort to minimize network and memory usage,
/// messages are fetched by page (batches of messages): this allows you to
/// easily create an infinite list, loading more messages on demand.
///
/// While you can configure the maximum number of messages you want in a page,
/// the actual number of returned messages can differ, as the SDK may filter
/// some of the messages returned by the server
/// (such as duplicate notifications, etc...).
///
/// Please MAKE SURE to call [dispose()] once you're done with the fetcher
/// (for example, when the user navigates away).
/// This should usually be done in your State's dispose method.
/// Failure to do so will leak memory, as Batch will not know that the associated
/// native object can be released, and the message channel freed.
///
/// As BatchInboxFetcher caches answers from the server, instances
/// of this class should be tied to the lifecycle of
/// the UI consuming it (if applicable).
///
/// Another reason to keep the object around, is that you cannot mark a
/// message as read with another BatchInboxFetcher instance that the one
/// that gave you the message in the first place, as this relies on internal
/// data structures that are only loaded in memory.
///
/// You can also set a upper messages limit, after which BatchInbox will stop
/// fetching new messages, even if you call fetchNextPage.
abstract class BatchInboxFetcher {
  /// Call this once you're finished with this fetcher to release the native
  /// object and free all memory. Usually, this should be called
  /// in your State's dispose.
  /// Due to dart/flutter limitations, not calling this will leak memory.
  ///
  /// Calling any method after calling dispose will result in an exception
  /// being thrown.
  void dispose();
}
