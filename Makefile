.PHONY: docs doc doc-ios doc-android build-ios-doc

docs: doc doc-ios doc-android

doc:
	dart doc --output api_docs/flutter-api-reference

# Build the iOS DocC archive for the batch_flutter module and place it in api_docs
build-ios-doc:
	rm -rf api_docs/batch_flutter.doccarchive
	cd example/ios && \
		xcodebuild docbuild \
			-workspace Runner.xcworkspace \
			-scheme batch_flutter \
			-destination 'generic/platform=iOS' \
			-derivedDataPath build-docs
	@DOC_ARCHIVE=$$(/usr/bin/find example/ios/build-docs -type d -name 'batch_flutter.doccarchive' -print -quit); \
		if [ -z "$$DOC_ARCHIVE" ]; then echo "DocC archive not found in example/ios/build-docs"; exit 1; fi; \
		mkdir -p api_docs; \
		rm -rf api_docs/batch_flutter.doccarchive; \
		mv "$$DOC_ARCHIVE" api_docs/batch_flutter.doccarchive

doc-ios: build-ios-doc
	rm -rf api_docs/flutter-ios-api-reference
	`xcrun -find docc` process-archive transform-for-static-hosting  ./api_docs/batch_flutter.doccarchive --hosting-base-path flutter-ios-api-reference --output-path ./api_docs/flutter-ios-api-reference

doc-android:
	rm -rf api_docs/flutter-android-api-reference
	cd example/android && ./gradlew :batch_flutter:generateJavadocRelease
