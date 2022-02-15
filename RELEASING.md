# Release process
(For Batch only)

- If you don't have one already, make a company pub.dev account and get it invited into the batch publisher account
- Bump versions in:
  - Changelog.md
  - pubspec.yaml
  - batch_flutter.podspec
  - Plugin version env vars: Search for "Flutter/". There should be two constants: one for Android, one for iOS. Bump the version there.
- Run `pod update` in `example/ios`
- Tag the commit
- Merge `dev` into `master`
- Make the Github release
- Update the documentation with the new changelog
- Clone the repository in a temporary folder so that no temporary artifact is pushed (pub publish doesn't honor gitignore well)
- Run `dart pub publish`