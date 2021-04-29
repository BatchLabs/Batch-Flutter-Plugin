## How to develop

### iOS

The plugin can be developed with the example project after running an initial `flutter build ios --no-codesign`.

If you need to create a new native source file, add it in `ios/Classes/`, go to `example/ios` and run `pod install`. Creating the file in Xcode will work, but it will be referenced with a wrong path, breaking autocompletion.

## Releasing

## API Documentation

### Flutter

Run `make doc`. You will need dartdoc for this: `flutter pub global activate dartdoc`. You might need to update your $PATH.

### iOS & Android native code

iOS requires [swift-doc](https://github.com/SwiftDocOrg/swift-doc) to be installed. Run `make doc-ios`