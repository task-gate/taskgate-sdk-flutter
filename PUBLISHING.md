# Publishing TaskGate Flutter SDK to pub.dev

This guide explains how to publish the TaskGate Flutter SDK to pub.dev.

## Prerequisites

### 1. Required Files (Already Set Up ✓)
- [x] `pubspec.yaml` - Package metadata
- [x] `LICENSE` - License file
- [x] `CHANGELOG.md` - Version history
- [x] `README.md` - Package documentation

### 2. Google Account
You need a Google account to publish to pub.dev. The first time you publish, you'll be asked to:
- Sign in with Google
- Grant pub.dev permission to publish packages on your behalf

### 3. Package Name
- Package name: `taskgate_sdk`
- **Important**: Once published, you cannot change the package name
- Verify on pub.dev that the name isn't taken: https://pub.dev/packages/taskgate_sdk

## Publishing Process

### Step 1: Prepare for Release

Update version and changelog:

```bash
# Edit pubspec.yaml - update version
# Edit CHANGELOG.md - add release notes for this version
```

Or use the deployment script to do this automatically:

```bash
cd /path/to/taskgate-mobile/sdk
./deploy-flutter.sh 1.0.1
```

### Step 2: Validate Package

Before publishing, validate your package:

```bash
cd flutter/taskgate_sdk
flutter pub get
dart pub publish --dry-run
```

This checks:
- Package follows pub.dev conventions
- All required files are present
- No warnings or errors
- Package size is reasonable

### Step 3: Publish to pub.dev

```bash
cd flutter/taskgate_sdk
dart pub publish
```

**First Time Publishing:**
1. You'll see package details and be asked to confirm
2. A browser will open for Google authentication
3. Sign in with your Google account
4. Grant pub.dev permissions
5. Return to terminal and confirm publication

**Subsequent Publishes:**
- Authentication is cached
- Just confirm the publication

### Step 4: Verify Publication

After publishing:
- View on pub.dev: https://pub.dev/packages/taskgate_sdk
- It may take a few minutes to appear in search
- Pub.dev will run automated analysis and assign a pub points score

## Using the Deployment Script

We've created a script that automates most of the process:

```bash
./deploy-flutter.sh 1.0.1
```

This script:
1. ✅ Updates version in `pubspec.yaml`
2. ✅ Runs package validation
3. ✅ Creates git commit and tag
4. ✅ Pushes to GitHub
5. ⚠️  Prompts you to run `dart pub publish` manually

**Note:** The actual `dart pub publish` command must be run manually because it requires interactive authentication.

## Version Management

Current version: **1.0.0**

To release a new version:
1. Update version in `pubspec.yaml`
2. Add entry to `CHANGELOG.md`
3. Run `./deploy-flutter.sh <version>`
4. Manually run `dart pub publish`

Follow semantic versioning:
- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Minor** (1.0.0 → 1.1.0): New features, backward compatible
- **Patch** (1.0.0 → 1.0.1): Bug fixes

## Package Requirements Checklist

Before publishing, ensure:

- [ ] Package name is available on pub.dev
- [ ] `pubspec.yaml` has all required fields:
  - [x] name
  - [x] description (60-180 characters)
  - [x] version
  - [x] homepage
  - [x] repository
  - [x] environment (SDK constraints)
- [ ] `README.md` is clear and helpful
- [ ] `CHANGELOG.md` is up to date
- [ ] `LICENSE` file is present
- [ ] No sensitive data in code
- [ ] Code follows Dart style guide
- [ ] `dart pub publish --dry-run` passes
- [ ] Package size is reasonable (< 100 MB)

## After Publishing

### Users can install your package:

```yaml
dependencies:
  taskgate_sdk: ^1.0.0
```

### Monitor your package:

- **Pub.dev page**: https://pub.dev/packages/taskgate_sdk
- **Pub points**: Check automated analysis score
- **Popularity**: Track download statistics
- **Issues**: Monitor GitHub issues

## Updating Published Package

To publish an update:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with changes
3. Run validation: `dart pub publish --dry-run`
4. Publish: `dart pub publish`

**Important:**
- You cannot unpublish a package version
- You cannot replace a published version
- Always test thoroughly before publishing

## Troubleshooting

### "Package name already exists"
The package name is taken. Choose a different name in `pubspec.yaml`.

### "Authentication failed"
Run `dart pub logout` then try publishing again.

### "Package validation failed"
Read the error messages carefully and fix issues in your code/configuration.

### "Package too large"
Check for unnecessary files. Add them to `.pubignore` to exclude from publication.

## Links

- Pub.dev Publishing Guide: https://dart.dev/tools/pub/publishing
- Package Layout Conventions: https://dart.dev/tools/pub/package-layout
- Pub.dev: https://pub.dev/
- Your Package: https://pub.dev/packages/taskgate_sdk
