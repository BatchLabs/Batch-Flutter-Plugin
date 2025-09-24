.PHONY: docs doc doc-ios doc-android build-ios-doc setup-build-ios flutter-setup

# Common Flutter setup - run once to avoid redundancy
flutter-setup:
	flutter pub get
	flutter config --no-enable-swift-package-manager
	flutter pub global activate dartdoc

docs: flutter-setup doc doc-ios doc-android

# Setup and build iOS project only
setup-build-ios: flutter-setup
	cd example && flutter build ios --no-codesign

doc: flutter-setup
	mkdir -p api_docs
	flutter pub global run dartdoc --output api_docs/flutter-api-reference

# Default to Jazzy, fallback to DocC
build-ios-doc: setup-build-ios doc-ios-jazzy

# Build the iOS DocC archive for the batch_flutter module and place it in api_docs
doc-ios-docc:
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

# Alternative: Use Jazzy for iOS documentation (better GitHub Pages compatibility)
doc-ios-jazzy: setup-build-ios
	rm -rf api_docs/flutter-ios-api-reference
	mkdir -p api_docs/flutter-ios-api-reference
	@if command -v jazzy >/dev/null 2>&1; then \
		echo "Generating iOS documentation with Jazzy..."; \
		cd example/ios && jazzy \
			--clean \
			--author "Batch" \
			--author_url "https://batch.com" \
			--github_url "https://github.com/BatchLabs/Batch-Flutter-Plugin" \
			--module "batch_flutter" \
			--output "../../api_docs/flutter-ios-api-reference" \
			--theme fullwidth \
			--swift-build-tool xcodebuild \
			--build-tool-arguments -workspace,Runner.xcworkspace,-scheme,batch_flutter,-destination,generic/platform=iOS \
			--readme "../../README.md" \
			--min-acl public \
			--hide-documentation-coverage || { \
				echo "Jazzy failed, falling back to DocC..."; \
				$(MAKE) doc-ios-docc; \
			}; \
	else \
		echo "Jazzy not installed. Install with: gem install jazzy"; \
		echo "Falling back to DocC..."; \
		$(MAKE) doc-ios-docc; \
	fi

# Original DocC approach (kept as fallback)
doc-ios-docc: build-ios-doc
	rm -rf api_docs/flutter-ios-api-reference
	mkdir -p api_docs/flutter-ios-api-reference
	@if [ -d "./api_docs/batch_flutter.doccarchive" ]; then \
		echo "Transforming DocC archive for static hosting..."; \
		`xcrun -find docc` process-archive transform-for-static-hosting \
			./api_docs/batch_flutter.doccarchive \
			--output-path ./api_docs/flutter-ios-api-reference \
			--hosting-base-path "flutter-ios-api-reference"; \
	else \
		echo "ERROR: DocC archive not found at ./api_docs/batch_flutter.doccarchive"; \
		exit 1; \
	fi

doc-ios: build-ios-doc

doc-android:
	rm -rf api_docs/flutter-android-api-reference
	cd example/android && ./gradlew :batch_flutter:generateJavadocRelease
