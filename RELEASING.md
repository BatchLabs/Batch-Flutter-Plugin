# Release process
(For Batch only)

- If you don't have one already, make a company pub.dev account and get it invited into the batch publisher account
- Bump versions in:
  - Changelog.md
  - pubspec.yaml
  - Plugin version env vars: Search for "Flutter/". There should be two constants: one for Android, one for iOS. Bump the version there.
- Tag the commit
- Merge `dev` into `master`
- Make the Github release
- Update the documentation with the new changelog
- Run `dart pub publish`