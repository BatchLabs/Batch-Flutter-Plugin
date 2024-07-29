## How to develop

### iOS

The plugin can be developed with the example project after running an initial `flutter build ios --no-codesign`.

If you need to create a new native source file, add it in `ios/Classes/`, go to `example/ios` and run `pod install`. Creating the file in Xcode will work, but it will be referenced with a wrong path, breaking autocompletion.

## Releasing

## API Documentation

If you have all of the dependencies installed, you can run `make docs` and copy the api_docs subdirectories in the documentation repository.  

Otherwise, you can build a specific platform:  

### Flutter

Run `make doc`. You will need dartdoc for this: `flutter pub global activate dartdoc`. You might need to update your $PATH.

### iOS & Android native code

iOS requires to build the .doccarchive beforehand from xcode -> product -> build documentation -> export batch_flutter to api_docs folder and then run `make doc-ios`.

Android doesn't require anything than a standard toolchain. You might need to set Android Studio's JVM as your `JAVA_HOME`. Run `make doc-android`.
