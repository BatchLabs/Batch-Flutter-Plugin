# batch_flutter Roadmap

This document describes the development milestones, leading to a stable release (1.0).

During development, day to day development will happen on the `dev` branch, and `master` will only be updated with tagged releases.

The documentation will not be available on `doc.batch.com`, but on [https://flutter-doc-preview.batchers.vercel.app/](https://flutter-doc-preview.batchers.vercel.app/).

## Beta 1 (0.0.1)

- Basics: start, configuration
- Mobile Landings & In-App messaging in automatic mode
- Get Installation ID
- First documentation draft

## Beta 2 (0.0.2)

- User consent (opt-in, opt-out)
- User data: `BatchUserDataEditor`, `trackEvent`, `trackTransaction`, `trackLocation`
- Debug view

## Beta 3 (0.0.3)

- User data: `fetchAttributes`/`fetchTags`
- Inbox:
  - Installation and User based fetchers
  - Mark as read/mark as deleted (might be delayed to another seed)

## Beta 4 (0.0.4)

- iOS foreground push setting
- In-App Messaging "Do Not Disturb"
- Inbox:  
  - Mark as read/deleted if pushed back from Beta 3
- Advanced documentation (Huawei integration, etc...)

## RC1 (0.1.0)

- First pub.dev publication
- Complete documentation
- Anything that might have been delayed from earlier betas

## 1.0.0

- All features mentioned above
- Release on pub.dev as stable