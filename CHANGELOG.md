## 1.0.0

**Initial stable release 🎉**

Changes since RC:  

**Inbox**

* Removed `isDeleted` on `BatchInboxNotificationContent` as it doesn't work like it does on the native SDK due to plugin limitations.

## 1.0.0-rc.2

**Inbox**

* Fix `limit` and `maxPageSize` staying at their default values.

## 1.0.0-rc.1 / 0.1.0

_First Release Candidate_

**Messaging**

* Added Do Not Disturb support.

**Inbox**

* Calling `dispose()` on a disposed fetcher doesn't throw anymore.
* Added `markAsRead()`, `markAllAsRead()` and `markAsDeleted()`.
* Added `limit` and `maxPageSize` to `getFetcherForInstallation()` and `getFetcherForUser()`.

## 0.0.3

**Inbox**

* Added Batch Inbox support:  
  - Fetchers can be instanciated for both Installation and User modes.
  - `fetchNewNotifications()`, `fetchNextPage()`, `get allNotifications` and `dispose()` have been implemented.
  - `markAsRead()`, `markAsDeleted()` and pagination configuration will come in a later beta.

**Push**

* Added `setShowForegroundNotificationsOniOS()`, which can enable foreground notification display on iOS.  
  Note: This requires `BatchUNUserNotificationCenterDelegate` to be set as your `UNUserNotificationCenterDelegate` in the native integration.

**User**

* Added `get attributes` and `get tagCollections` properties to read back previously set attributes and tag collections.
* Added `get identifier`, `get language` and `get region` to read back the user identifier and language/region overrides.

## 0.0.2

**Core**

* Added `showDebugView()`.
* Added `optIn()`, `optOut()` and `optOutAndWipeData()`.
  - `isOptedOut` will come in a later seed.

**Push**

* Added `requestProvisionalNotificationAuthorization()`.

**User**

* Added `trackEvent()`, `trackTransaction()`, `trackLocation()` and the `BatchEventData` class.
* Added `newEditor()` which returns a `BatchUserDataEditor` instance, allowing you to edit the user profile (attributes, tags, language/region, custom identifier).

## 0.0.1

* First Batch Flutter plugin beta release.
