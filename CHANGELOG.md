## 1.4.0

**Plugin**

* Dart 2.15+ is now required.
* Updated Batch to 1.21.0. 
* Batch requires iOS 12.0 or higher.
* Batch now compiles with and targets SDK 34 (Android 14).

**User**

* Removed automatic collection of the advertising id:
  * Android's Methods `setCanUseAdvertisingID` and `canUseAdvertisingID` from `BatchPluginConfiguration` are now deprecated and do nothing.
  * Android's manifest configuration `com.batch.flutter.use_gaid` has been removed.
  * iOS's property `canUseIDFA` from `BatchPluginConfiguration` is now deprecated and does nothing.
  * iOS's Info.plist property `BatchFlutterCanUseIDFA` has been removed.
  * You need to collect it from your side and pass it to Batch via the added `setAttributionIdentifier(String? id)` method. Batch will persist it across starts.
* Added `setEmail(String? email)` method to `BatchUserDataEditor`. This requires to have a user identifier registered or to call the `setIdentifier` method on the editor instance beforehand.
* Added `setEmailMarketingSubscriptionState(BatchEmailSubscriptionState state)` method to `BatchUserDataEditor`. 

**Inbox**

* Added `hasLandingMessage` property to `BatchInboxNotificationContent`.
* Added `displayNotificationLandingMessage(BatchInboxNotificationContent notification)` method to `BatchInboxFetcher`.  

  
## 1.3.0

**Plugin**

* Updated Batch to 1.19.2.
  Bumping your Android project's `compileSdkVersion` to `33` might be required.
  Xcode 13.3 required if your project uses bitcode.

**Push**

* Added Android implementation of the `batch.push.requestNotificationAuthorization()` API. This allows you to request for the [new notification permission introduced](https://developer.android.com/about/versions/13/changes/notification-permission) in Android 13. See the documentation for more info.

## 1.2.0

**Plugin**

* Updated Batch to 1.19.0.
  Bumping your Android project's `compileSdkVersion` to `31` might be required.
  Xcode 13.3 required if your project uses bitcode.

**Inbox**

* Silent notifications are now filtered on Android rather than throwing an exception when fetched.

## 1.1.4

**Plugin**

* Android: Move away from jCenter and use Maven Central.

## 1.1.3

**Plugin**

* Updated dependencies so that the project can be built using Flutter 2.10.  
  Bumping your Android project's `compileSdkVersion` to `31` might be required.

## 1.1.2

**Plugin**

* Android: Fixed an issue where Batch's "advanced device information" was disabled by default and not configurable using the Manifest.
* Android: Manifest configuration of the initial Do Not Disturb state now works as expected.

## 1.1.1

**Plugin**

* Update Batch iOS to 1.18.1
* Work around a [Flutter issue](https://github.com/flutter/flutter/issues/67624#issuecomment-801971172) where a wrong nullability annotation resulted in a debug app crashing when started from the home screen.
  The scenario is still unsupported by Flutter, but the app will not crash anymore.

## 1.1.0

**Plugin**

* Update Batch to 1.18

**User**

* Added support for the URL attribute and event data type.

## 1.0.0

**Initial stable release 🎉**

_Changes since RC:_ 

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
