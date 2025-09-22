## 3.0.0

**Plugin**
* Updated Batch to 3.1
* Batch requires iOS 15.0 or higher and Xcode 16.4
* Batch now compiles with SDK 36 (Android 16 'Baklava').
* Change framework to dynamic

**Push**
- Added `setShowNotifications` method to control whether android push notifications should be displayed.
- Added `shouldShowNotifications` method to check current android notification display settings.

**Messaging**
- Added support for Mobile Landings within the Customer Engagement Platform.
- Added support for In-App Automations within the Customer Engagement Platform.

## 2.1.0

**Plugin**
* Updated Batch to 2.1
* Batch requires iOS 13.0 or higher.
* Batch requires to compile with SDK 35 (Android 15).

**iOS**
- Added support for Swift Package Manager. Since, as of writing, [Flutter's support of SPM](https://docs.flutter.dev/packages-and-plugins/swift-package-manager) is still under development, this may not work in future versions of Flutter. Batch is still backwards compatible with CocoaPods.

**Profile**
- Added `setPhoneNumber` API to the `BatchProfileAttributeEditor` class. This requires to have a user identifier registered or to call the `identify` method beforehand.
- Added `setSMSMarketingSubscription` API to the `BatchProfileAttributeEditor` class.

## 2.0.0

This is a major release, please see our [migration guide](https://doc.batch.com/flutter/advanced/1x-migration/) for more info on how to update your current Batch implementation.

**Plugin**
* Updated Batch to 2.0. For more information see the [ios](https://doc.batch.com/ios/sdk-changelog/#2_0_0) and [android](https://doc.batch.com/android/sdk-changelog/#2_0_0) changelog .
* Batch requires iOS 13.0 or higher.
* Batch requires a `minSdk` level of 21 or higher.

**iOS**

- Removed deprecated `canUseIDFA` property from `BatchPluginConfiguration`.
- Removed `canUseAdvancedDeviceInformation`property from `BatchPluginConfiguration`. You should now use the `setAutomaticDataCollection` API.
- Added `profileCustomIdMigrationEnabled` property to disable the profile custom id migration. This can also be done from the `Info.plist` file. See our documentation for info.
- Added `profileCustomDataMigrationEnabled` property to disable the profile custom data migration. This can also be done from the `Info.plist` file. See our documentation for info.

**Android**

- Removed deprecated `canUseAdvertisingID` method from `BatchPluginConfiguration`.
- Removed `setCanUseAdvancedDeviceInformation` and `canUseAdvancedDeviceInformation` method from `BatchPluginConfiguration`. You should now use the new `setAutomaticDataCollection` API.
- Added `setProfileCustomIdMigrationEnabled` method to disable the profile custom id migration. This can also be done from the `AndroidManifest` meta-data. See our documentation for info.
- Added `setProfileCustomDataMigrationEnabled` method to disable the profile custom data migration. This can also be done from the `AndroidManifest` meta-data. See our documentation for info.

**Core**
- Added method `isOptedOut` to checks whether Batch has been opted out from or not.
- Added method `setAutomaticDataCollection` to fine-tune the data you authorize to be tracked by Batch.

**User**
- Removed method `trackTransaction` with no equivalent.
- Removed method `BatchUser.newEditor` and the related class `BatchUserDataEditor`, you should now use `BatchProfile.instance.newEditor()` which return an instance of `BatchProfileAttributeEditor`.
- Added method `clearInstallationData` which allows you to remove the installation data without modifying the current profile.

**Event**

This version introduced two new types of attribute that can be attached to an event : Array and Object.

- Removed `trackEvent` APIs from the user module. You should now use `BatchProfile.instance.trackEvent`.
- `BatchEventData` has been renamed into `BatchEventAttributes`.
- Added support of type Array and Object with the following:
  - Added `putObject` method to `BatchEventAttributes`.
  - Added `putObjectList` method `BatchEventAttributes`.
  - Added `putStringList` method `BatchEventAttributes`.
- Removed `addTag` API from `BatchEventData` You should now use the `$tags` key in `BatchEventAttributes` with the `putStringList` method.
- Removed parameter `label` from `trackEvent` API. You should now use the `$label` key in `BatchEventAttributes` with the `putString` method.

**Profile**

Introduced `BatchProfile`, a new module that enables interacting with profiles. Its functionality replaces most of BatchUser used to do.

- Added `identify` API as replacement of `BatchUser.instance.newEditor().setIdentifier`.
- Added `newEditor` method to get a new instance of a `BatchProfileAttributeEditor` as replacement of `BatchUserDataEditor`.
- Added `trackEvent` API as replacement of the `BatchUser.instance.trackEvent` methods.
- Added `trackLocation` API as replacement of the `BatchUser.instance.trackLocation` method.


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
