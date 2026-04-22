# Violet — macOS DMG Build & Distribution Guide

**NEXTGEN CARE SERVICES LTD** | Internal Developer Documentation | Confidential

---

## Overview

This guide explains the complete process to build, sign, notarise, and distribute the Violet macOS app as a `.dmg` installer. Follow every step in order — skipping any step will cause the build to fail or show security warnings on user machines.

---

## Prerequisites

Before starting, make sure you have the following:

| Tool | Check |
|------|-------|
| Flutter SDK installed | `flutter doctor` |
| Xcode installed | Mac App Store |
| CocoaPods installed | `sudo gem install cocoapods` |
| `create-dmg` installed | `brew install create-dmg` |
| Apple Developer Account | developer.apple.com |
| `.icns` icon file ready | Located at project root |

---

## Full Process — Step by Step

---

### Step 1 — Open & Build the Flutter Project

```bash
cd /path/to/your/flutter/project
flutter build macos --release
```

---

### Step 2 — Open in Xcode

```bash
open macos/Runner.xcworkspace
```

Xcode will open automatically.

---

### Step 3 — Configure Signing in Xcode

Go to **Xcode → Runner Target → Signing & Capabilities** and make the following changes:

| Setting | Value |
|---------|-------|
| Automatically manage signing | OFF |
| Team | NEXTGEN CARE SERVICES LTD |
| Signing Certificate | Developer ID Application |

**Important:** Make sure Hardened Runtime capability is added.
Click **+ Capability** → search **Hardened Runtime** → Add.

---

### Step 4 — Archive the Build

```
Product → Archive
```

Wait for the archive to complete. The Organizer window will open automatically.

---

### Step 5 — Distribute with Direct Distribution

In the Organizer window:

```
Distribute App
  → Custom
    → Direct Distribution
      → Export
```

This signs the app with your Developer ID Application certificate.

---

### Step 6 — Locate the Exported App

After export, open the exported folder. You will see:

```
Export Folder
  ├── Violet.app
  ├── ExportOptions.plist
  ├── packaging.log
  └── Distribution Summary.pdf
```

Keep all files. Only `Violet.app` is used for the next steps.

---

### Step 7 — Create App-Specific Password

1. Go to https://account.apple.com/
2. Navigate to **Sign-In & Security → App-Specific Passwords**
3. Click **Generate**
4. Label it: `Violet Notarization`
5. Copy the generated password in format: `xxxx-xxxx-xxxx-xxxx`

Store this password safely. You will need it for every release.

---

### Step 8 — ZIP the App

```bash
cd /path/to/export/folder
ditto -c -k --keepParent "Violet.app" "Violet.zip"
```

---

### Step 9 — Notarise with Apple

```bash
xcrun notarytool submit Violet.zip --wait \
  --apple-id "your@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "xxxx-xxxx-xxxx-xxxx"
```

Replace the placeholders:

| Placeholder | What to enter |
|-------------|---------------|
| `your@email.com` | Your Apple ID email |
| `YOUR_TEAM_ID` | Found at developer.apple.com/account → Membership |
| `xxxx-xxxx-xxxx-xxxx` | App-specific password from Step 7 |

Success output:

```
Processing complete
  status: Accepted
```

---

### Step 10 — Staple the Notarisation Ticket

```bash
xcrun stapler staple Violet.app
```

Success output:

```
The staple and validate action worked!
```

---

### Step 11 — Prepare for DMG Creation

Move `Violet.app` into a new empty folder by itself before creating the DMG. No other files should be in the source folder.

```
Clean Folder
  └── Violet.app
```

---

### Step 12 — Create the DMG

```bash
create-dmg \
  --volname "Violet" \
  --volicon "/path/to/project/macos_icon.icns" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "Violet.app" 175 190 \
  --hide-extension "Violet.app" \
  --app-drop-link 425 190 \
  "/output/path/Violet-1.0.0.dmg" \
  "/source/folder/with/only/Violet.app/"
```

Update these paths for your machine:

| Parameter | Description |
|-----------|-------------|
| `--volicon` | Path to your `.icns` file at project root |
| Second last line | Where the final `.dmg` will be saved |
| Last line | Folder containing only `Violet.app` |

---

### Step 13 — Done

Your final `.dmg` file is ready for distribution.

Upload `Violet-1.0.0.dmg` to your website or share with organisations directly.

---

## For Every New Version

Repeat Steps 1 to 13 and change the version number in the DMG filename:

```bash
"/output/path/Violet-2.0.0.dmg"
```

Always run Xcode Archive for every new build. You cannot reuse an old `.app` for a new version.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Hardened Runtime error | Add Hardened Runtime in Xcode → Signing & Capabilities |
| Developer ID error | Change Signing Certificate from Development to Developer ID Application |
| 401 Invalid credentials | Generate a new App-Specific Password at appleid.apple.com |
| Not enough arguments in create-dmg | Run the command as a single line to avoid copy-paste line break issues |
| DMG has extra files inside | Ensure source folder contains only `Violet.app` |
| App shows security warning on user Mac | Notarisation or stapling was skipped — redo Steps 9 and 10 |

---

## Where to Find Important Values

| Value | Where to Find |
|-------|---------------|
| Team ID | [developer.apple.com/account](https://developer.apple.com/account) → Membership Details |
| App-Specific Password | [account.apple.com](https://account.apple.com) account.apple.com → Sign-In & Security |
| Developer ID Certificate | Xcode → Settings → Accounts → Manage Certificates |
| `.icns` icon file | Project root folder |

---

## Release Log

| Version | Date | Built By | Notes |
|---------|------|----------|-------|
| 1.0.0 | April 2026 | [Bayajit Islam](https://github.com/BayajitIslam) | Initial Release |
| | | | |
| | | | |

NEXTGEN CARE SERVICES LTD | Violet AI Platform | Internal Documentation
