## UPCOMING

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
