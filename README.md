# batch_flutter

A new flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## How to develop

### iOS

The plugin can be developed with the example project after running an initial `flutter build ios --no-codesign`.

If you need to create a new native source file, add it in `ios/Classes/`, go to `example/ios` and run `pod install`. Creating the file in Xcode will work, but it will be referenced with a wrong path, breaking autocompletion.