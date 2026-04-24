<div align="center">

# Violet — AI Support Platform

### Build & Distribution Guide

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows-blue)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B)
![Status](https://img.shields.io/badge/Status-Production-green)
![Version](https://img.shields.io/badge/Version-1.0.0-purple)

---

| | |
|:---:|:---:|
| **Maintained by** | [Bayajit Islam](https://github.com/BayajitIslam) |
| **Organisation** | Nextgen Care Services Ltd |
| **Last Updated** | April 2026 |
| **Classification** | Internal Developer Documentation |

---

### Select your platform

| [macOS — DMG Installer](#macos--dmg-build--distribution-guide) | [Windows — EXE Installer](#windows--exe-build--distribution-guide) |
|:---:|:---:|
| Build, sign, notarise and distribute a `.dmg` installer | Build and package a `.exe` installer with Inno Setup |

</div>

---

<br/>

---

# macOS — DMG Build & Distribution Guide

## Overview

This guide covers the complete process to build, sign, notarise, and distribute the Violet macOS application as a `.dmg` installer.

Follow every step in order. Skipping any step will cause the build to fail or show security warnings when users attempt to install the app.

---

## Prerequisites

Ensure the following tools and accounts are in place before starting.

| Requirement | How to verify |
|-------------|---------------|
| Flutter SDK | `flutter doctor` |
| Xcode | Mac App Store |
| CocoaPods | `sudo gem install cocoapods` |
| Homebrew | `brew --version` |
| create-dmg | `brew install create-dmg` |
| Apple Developer Account | [developer.apple.com](https://developer.apple.com) |
| Developer ID Application Certificate | Xcode → Settings → Accounts → Manage Certificates |
| `.icns` icon file | Located at project root |

---

## Step by Step

---

### Step 1 — Flutter Release Build

Open Terminal, navigate to the project directory and run the release build.

```bash
cd /path/to/violet/project
flutter build macos --release
```

Verify the output exists before continuing:

```bash
ls build/macos/Build/Products/Release/
```

You should see `Violet.app` in the output.

---

### Step 2 — Open the Project in Xcode

```bash
open macos/Runner.xcworkspace
```

Xcode will open the project automatically. Do not open the `.xcodeproj` file directly.

---

### Step 3 — Configure Signing in Xcode

Navigate to **Xcode → Runner Target → Signing & Capabilities** and apply the following settings:

| Setting | Required Value |
|---------|----------------|
| Automatically manage signing | **Off** |
| Team | Your team name |
| Signing Certificate | **Developer ID Application** |

**Add Hardened Runtime capability**

This is required for Apple notarisation. Without it the submission will be rejected.

```
Signing & Capabilities → + Capability → search "Hardened Runtime" → Add
```

---

### Step 4 — Archive the Build

```
Xcode menu → Product → Archive
```

Wait for the archive process to complete. The Organizer window will open automatically when done.

---

### Step 5 — Export with Direct Distribution

In the Organizer window, select your archive and proceed as follows:

```
Distribute App
  → Custom
    → Direct Distribution
      → Export
```

Select a destination folder and click Export. This signs the app using your Developer ID Application certificate.

> Do not select App Store Connect or Debugging. These will not produce a correctly signed build for direct distribution.

---

### Step 6 — Locate the Exported App

Open the export destination folder. You will find the following files:

```
Export Folder
  ├── Violet.app                  ← Required for next steps
  ├── ExportOptions.plist         ← Keep for reference
  ├── packaging.log               ← Keep for debugging
  └── Distribution Summary.pdf    ← Keep as signing record
```

Only `Violet.app` is needed for notarisation and DMG creation. Keep the other files for your records.

---

### Step 7 — Generate an App-Specific Password

An app-specific password is required to authenticate with Apple's notarisation service.

1. Go to [account.apple.com](https://account.apple.com)
2. Navigate to **Sign-In & Security → App-Specific Passwords**
3. Click **Generate**
4. Enter the label: `Violet Notarization`
5. Copy the generated password — format: `xxxx-xxxx-xxxx-xxxx`

Store this securely. A new password must be generated for each release.

---

### Step 8 — Create a ZIP for Submission

Navigate to the export folder and create a ZIP of the app.

```bash
cd /path/to/export/folder
ditto -c -k --keepParent "Violet.app" "Violet.zip"
```

---

### Step 9 — Submit for Notarisation

```bash
xcrun notarytool submit Violet.zip --wait \
  --apple-id "your@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "xxxx-xxxx-xxxx-xxxx"
```

Replace each placeholder with your actual credentials:

| Placeholder | Where to find it |
|-------------|-----------------|
| `your@email.com` | Your Apple ID email address |
| `YOUR_TEAM_ID` | developer.apple.com/account → Membership Details |
| `xxxx-xxxx-xxxx-xxxx` | App-specific password from Step 7 |

**Accepted output:**

```
Processing complete
  id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  status: Accepted
```

If the status is `Invalid`, run the following to retrieve the error log:

```bash
xcrun notarytool log <submission-id> \
  --apple-id "your@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "xxxx-xxxx-xxxx-xxxx"
```

---

### Step 10 — Staple the Notarisation Ticket

Stapling attaches the notarisation result directly to the app so it can be verified offline on end-user machines.

```bash
xcrun stapler staple Violet.app
```

**Success output:**

```
The staple and validate action worked!
```

Verify the result:

```bash
xcrun stapler validate Violet.app
```

---

### Step 11 — Prepare the Source Folder

Before creating the DMG, move `Violet.app` into a new empty folder. The source folder must contain only the app — no other files.

```
/clean-folder/
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
  "/clean-folder/"
```

Update the following paths before running:

| Parameter | What to enter |
|-----------|---------------|
| `--volicon` | Full path to your `.icns` file at project root |
| Second last argument | Full path and filename for the output `.dmg` |
| Last argument | Full path to the clean folder containing only `Violet.app` |

If the command fails due to line break issues when copy-pasting, run it as a single line:

```bash
create-dmg --volname "Violet" --volicon "/path/to/macos_icon.icns" --window-pos 200 120 --window-size 600 400 --icon-size 100 --icon "Violet.app" 175 190 --hide-extension "Violet.app" --app-drop-link 425 190 "/output/Violet-1.0.0.dmg" "/clean-folder/"
```

---

### Step 13 — Distribution

Your signed, notarised DMG is ready.

```
Violet-1.0.0.dmg
```

Upload to your website or distribute directly to organisations. Users install by opening the DMG, dragging Violet to the Applications folder, and opening it from Applications or Launchpad.

---

## Building a New Version

Repeat Steps 1 to 13 for every new release. Update the version number in the DMG filename at Step 12.

```bash
"/output/path/Violet-2.0.0.dmg"
```

> You cannot reuse a previously exported `.app` for a new build. Always archive fresh from Xcode for each release.

---

## Generating the .icns Icon File

If you need to regenerate the app icon from a new PNG source (minimum 1024x1024):

```bash
mkdir MyIcon.iconset

sips -z 16 16     source.png --out MyIcon.iconset/icon_16x16.png
sips -z 32 32     source.png --out MyIcon.iconset/icon_16x16@2x.png
sips -z 32 32     source.png --out MyIcon.iconset/icon_32x32.png
sips -z 64 64     source.png --out MyIcon.iconset/icon_32x32@2x.png
sips -z 128 128   source.png --out MyIcon.iconset/icon_128x128.png
sips -z 256 256   source.png --out MyIcon.iconset/icon_128x128@2x.png
sips -z 256 256   source.png --out MyIcon.iconset/icon_256x256.png
sips -z 512 512   source.png --out MyIcon.iconset/icon_256x256@2x.png
sips -z 512 512   source.png --out MyIcon.iconset/icon_512x512.png
sips -z 1024 1024 source.png --out MyIcon.iconset/icon_512x512@2x.png

iconutil -c icns MyIcon.iconset --output macos_icon.icns
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Hardened Runtime error on notarisation | Add Hardened Runtime capability in Xcode → Signing & Capabilities |
| Developer ID certificate error | Change Signing Certificate from Development to Developer ID Application in Xcode |
| 401 Invalid credentials on notarytool | Generate a new App-Specific Password at account.apple.com — old passwords expire |
| Status: Invalid on notarisation | Run `notarytool log` with the submission ID to retrieve detailed errors |
| Not enough arguments in create-dmg | Run the full command as a single line without line breaks |
| Extra files appearing inside DMG | Ensure the source folder contains only `Violet.app` and nothing else |
| Security warning on user machine | Notarisation or stapling was skipped — redo Steps 9 and 10 |
| App not found after install | User must open from Applications folder or Launchpad — this is normal macOS behaviour |

---

## Reference

| Value | Where to find |
|-------|---------------|
| Team ID | [developer.apple.com/account](https://developer.apple.com/account) → Membership Details |
| App-Specific Password | [account.apple.com](https://account.apple.com) → Sign-In & Security → App-Specific Passwords |
| Developer ID Certificate | Xcode → Settings → Accounts → Manage Certificates |
| `.icns` icon file | Project root directory |

---

<br/>

---

# Windows — EXE Build & Distribution Guide

## Overview

This guide covers the complete process to build and package the Violet Windows application as a `.exe` installer using Inno Setup.

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Flutter SDK | `flutter doctor` |
| Windows 10 or 11 (x64) | Build machine must be Windows |
| Visual Studio | Desktop development with C++ workload required |
| Inno Setup | [jrsoftware.org/isinfo.php](https://jrsoftware.org/isinfo.php) |

---

## Step by Step

---

### Step 1 — Flutter Release Build

Open a terminal and run:

```bash
flutter clean
flutter pub get
flutter build windows --release
```

The compiled output will be located at:

```
build/windows/x64/runner/Release/
```

The main executable is:

```
build/windows/x64/runner/Release/violet.exe
```

---

### Step 2 — Create the Inno Setup Script

Create a file named `installer.iss` in your project root with the following content:

```iss
; ===== Violet Installer Script  =====

#define MyAppName "Violet"
#define MyAppVersion "1.8"
#define MyAppPublisher "Nxt Gen Care Services"
#define MyAppURL "https://nextgen-careservices.com"
#define MyAppExeName "violet.exe"

[Setup]
AppId={{F711BE9A-1D28-4B83-87D6-E4813C9593BD}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

UninstallDisplayIcon={app}\{#MyAppExeName}

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

PrivilegesRequired=admin
OutputBaseFilename=VioletInstaller

Compression=lzma
SolidCompression=yes
WizardStyle=modern

; YOUR ICON PATH
SetupIconFile=C:\Users\bayajitislam\violet\windows_icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
; INCLUDE FULL RELEASE FOLDER
Source: "C:\Users\bayajitislam\violet\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
```

---

### Step 3 — Compile the Installer

Open Inno Setup and compile the script:

```
Inno Setup → File → Open → select installer.iss
Build → Compile
```

The installer will be generated at:

```
Output/VioletInstaller-1.0.0.exe
```

---

### Step 4 — Distribution

Distribute `VioletInstaller-1.0.0.exe` to your organisations. Users run the installer and Violet will be installed with a desktop shortcut and Start Menu entry.

---

## Building a New Version

For every new release:

1. Run `flutter build windows --release`
2. Update `#define MyAppVersion` in `installer.iss`
3. Recompile with Inno Setup

---

## Important Notes

- Never distribute `violet.exe` on its own. The full `Release/` directory must be bundled via the installer as it contains required DLL files and assets.
- The installer targets x64 architecture only.
- Visual Studio must have the **Desktop development with C++** workload installed. Without this, the Flutter Windows build will fail.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `flutter build windows` fails | Ensure Visual Studio is installed with Desktop development with C++ workload |
| App crashes on user machine | Distribute via installer — do not share `violet.exe` alone |
| Missing DLL errors | Ensure all files from `Release/` folder are included via `recursesubdirs` in the installer script |
| Inno Setup compile error | Check that the `Source` path in `installer.iss` matches your actual build output path |

---

<br/>

---

## Release Log

| Version | Date | Platform | Built By | Notes |
|---------|------|----------|----------|-------|
| 1.0.0 | April 2026 | macOS + Windows | [Bayajit Islam](https://github.com/BayajitIslam) | Initial Release |
| | | | | |
| | | | | |

---

<div align="center">

Nextgen Care Services Ltd | Violet AI Platform | Internal Documentation | Confidential

</div>
