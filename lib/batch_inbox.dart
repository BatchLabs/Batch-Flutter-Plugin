import 'package:batch_flutter/src/inbox_fetcher.dart';

/// Batch Inbox module
class BatchInbox {
  /// Batch Inbox module singleton.
  static BatchInbox instance = new BatchInbox();

  /// Get an inbox fetcher for the current installation ID.
  Future<BatchInboxFetcher> getFetcherForInstallation() async {
    var fetcher = BatchInboxFetcherInstallationImpl();
    await fetcher.init();
    return fetcher;
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
    var fetcher = BatchInboxFetcherUserImpl(
        user: userIdentifier, authKey: authenticationKey);
    await fetcher.init();
    return fetcher;
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
  /// Get all of the notifications that have been fetched by this fetcher instance.
  ///
  /// Note: This doesn't cache anything on the Flutter side, but always asks
  /// the native code. Therefore, this is an expensive method to call: you should
  /// cache the result on your end.
  Future<List<BatchInboxNotificationContent>> get allNotifications;

  /// Fetch new notifications.
  /// While [fetchNextPage] is used to fetch older notifications than the ones currently loaded, this method checks for new notifications.
  /// For example, this is the method you would call on initial load, or on a "pull to refresh".
  /// The previously loaded notifications will be cleared to ensure consistency.
  /// Otherwise, a gap could be created between new notifications and your current set.
  /// Upon calling this method, please clear your cache and fill it with this
  /// method's results and ask again for more pages if you need.
  Future<BatchInboxFetchResult> fetchNewNotifications();

  /// Fetch a page of notifications.
  /// Calling this method when no messages have been loaded will be equivalent
  /// to calling [fetchNewNotifications];
  Future<BatchInboxFetchResult> fetchNextPage();

  /// Call this once you're finished with this fetcher to release the native
  /// object and free all memory. Usually, this should be called
  /// in your State's dispose.
  /// Due to dart/flutter limitations, not calling this will leak memory.
  ///
  /// Calling any method after calling dispose will result in an exception
  /// being thrown.
  void dispose();
}

/// Source of a notification. This is "what" triggered the push to be sent to the
/// user. Push Campaign, Transactional notification, ...
/// Unknown means that your SDK is too old to understand a new source that has
/// been introduced after its release.
enum BatchInboxNotificationSource { unknown, campaign, transactional, trigger }

/// Describes the content of an inbox notification.
class BatchInboxNotificationContent {
  /// Internal constructor.
  /// <nodoc>
  BatchInboxNotificationContent(this.id, this.title, this.body, this.isUnread,
      this.isDeleted, this.date, this.source, this.payload);

  /// The unique notification identifier. Do not make assumptions about its format: it can change at any time.
  final String id;

  /// Notification title. Optional.
  final String? title;

  /// Notification body.
  final String body;

  /// Is the notification unread?
  final bool isUnread;

  /// Is the notification deleted?
  final bool isDeleted;

  /// Notification timestamp in UTC.
  final DateTime date;

  /// Source of the notification. This is "what" triggered the push to be sent to the
  /// user. Push Campaign, Transactional notification, ...
  /// Unknown means that your SDK is too old to understand a new source that has
  /// been introduced after its release.
  final BatchInboxNotificationSource source;

  /// Raw notification payload.
  /// This is the complete payload containing Apple, Google, Batch's internal keys
  /// and the ones you can add using the custom payload feature.
  ///
  /// For consistency between iOS and Android, the payload is a String,String map
  /// with its values encoded as JSON for complex types.
  ///
  /// Keys in "com.batch" are private and should not be relied on.
  final Map<String, String> payload;
}

/// Describes a fetch operation result
class BatchInboxFetchResult {
  BatchInboxFetchResult({required this.notifications, required this.hasMore});

  /// Fetched notifications.
  final List<BatchInboxNotificationContent> notifications;

  /// Are more notifications available, or did we reach the end of the Inbox
  /// feed?
  final bool hasMore;
}

/// Error thrown when the [BatchInboxFetcher] object receives a method call
/// after [dispose] has been called.
class DisposedInboxError extends Error {
  @override
  String toString() {
    return "DisposedInboxError: BatchInboxFetcher instances cannot be used anymore once .dispose() has been called.";
  }
}

/// Error thrown when an internal inbox error happens.
class InboxInternalError extends Error {
  InboxInternalError({required this.code});

  final int code;

  @override
  String toString() {
    return "InboxInternalError: An internal inbox error has occurred, something might be wrong with the native implementation. Code: $code";
  }
}
