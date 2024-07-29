.PHONY: docs doc doc-ios doc-android

docs: doc doc-ios doc-android

doc:
	dartdoc build --output api_docs/flutter-api-reference

doc-ios:
	rm -rf api_docs/flutter-ios-api-reference
	`xcrun -find docc` process-archive transform-for-static-hosting  ./api_docs/batch_flutter.doccarchive --hosting-base-path flutter-ios-api-reference --output-path ./api_docs/flutter-ios-api-reference

doc-android:
	rm -rf api_docs/flutter-android-api-reference
	cd example/android && ./gradlew :batch_flutter:generateJavadocRelease
