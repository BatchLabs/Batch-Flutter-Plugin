.PHONY: docs doc doc-ios

docs: doc doc-ios

doc:
	dartdoc build --output api_docs/flutter-api-reference

doc-ios:
	swift-doc generate --module-name batch_flutter --format html --base-url "/flutter-ios-api-reference" ./ios/Classes/ -o "api_docs/flutter-ios-api-reference"