.PHONY: docs doc doc-ios doc-android

docs: doc doc-ios doc-android

doc:
	dartdoc build --output api_docs/flutter-api-reference

doc-ios:
	rm -rf api_docs/flutter-ios-api-reference
	swift-doc generate --module-name batch_flutter --format html --base-url "/flutter-ios-api-reference" ./ios/Classes/ -o "api_docs/flutter-ios-api-reference"

doc-android:
	rm -rf api_docs/flutter-android-api-reference
	cd example/android && ./gradlew :batch_flutter:generateJavadocRelease