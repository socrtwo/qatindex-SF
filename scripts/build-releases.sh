#!/usr/bin/env bash
# build-releases.sh — produce per-platform release bundles for the PWA.
# Usage:  bash scripts/build-releases.sh <version>
#         bash scripts/build-releases.sh v1.0.0   (a leading "v"/"V" is accepted)
#
# Output: dist/qatindex-<platform>-v<version>.{zip,tar.gz}
#         dist/SHA256SUMS
#         dist/RELEASE_NOTES.md
#
# Each bundle contains:
#   - The full PWA (web/) so it works offline
#   - A platform-appropriate launcher that opens the app
#   - PLATFORM_INSTALL.md with install steps for that platform

set -euo pipefail

# Normalize the version: callers may pass "1.0.0", "v1.0.0" or even "vV1.0.0".
# Strip every leading v/V so the emitted file names are always
# qatindex-<platform>-v<version> with exactly one "v".
RAW_VERSION="${1:-0.0.0}"
VERSION="$RAW_VERSION"
while [[ "$VERSION" == [vV]* ]]; do
  VERSION="${VERSION#[vV]}"
done
[ -n "$VERSION" ] || VERSION="0.0.0"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
WEB="$ROOT/web"

rm -rf "$DIST"
mkdir -p "$DIST"

if [ ! -d "$WEB" ]; then
  echo "FATAL: web/ directory missing" >&2
  exit 1
fi

stage() {
  local name="$1"
  local stagedir="$DIST/_stage/$name"
  rm -rf "$stagedir"
  mkdir -p "$stagedir/app"
  cp -r "$WEB"/. "$stagedir/app/"
  echo "$stagedir"
}

pkg_zip() {
  local name="$1" stagedir="$2"
  ( cd "$DIST/_stage" && zip -qr "$DIST/$name.zip" "$(basename "$stagedir")" )
  echo "  ✓ $name.zip"
}

pkg_tgz() {
  local name="$1" stagedir="$2"
  tar -C "$DIST/_stage" -czf "$DIST/$name.tar.gz" "$(basename "$stagedir")"
  echo "  ✓ $name.tar.gz"
}

# ----------------------------------------------------------------------
# Windows
# ----------------------------------------------------------------------
echo "▶ Windows"
S=$(stage "qatindex-windows-v$VERSION")
cat > "$S/Launch QAT Index.bat" <<'BAT'
@echo off
REM Launches the PWA in the user's default browser.
REM For best experience, install the app via the browser's install button
REM (URL bar, or browser menu -> "Install QAT Command Index").
setlocal
set "HERE=%~dp0app\index.html"
start "" "%HERE%"
endlocal
BAT
cat > "$S/PLATFORM_INSTALL.md" <<EOF
# QAT Command Index — Windows

## Quick start
1. Unzip this archive anywhere.
2. Double-click **Launch QAT Index.bat**.
3. Use it.

## Install as a real Windows app (recommended)
1. Open https://socrtwo.github.io/qatindex-SF/ in **Microsoft Edge** or **Chrome**.
2. Click the **install** icon in the address bar (or menu → "Install QAT Command Index").
3. The app appears in your Start menu and runs in its own window — works offline.

Version: $VERSION
EOF
pkg_zip "qatindex-windows-v$VERSION" "$S"

# ----------------------------------------------------------------------
# macOS
# ----------------------------------------------------------------------
echo "▶ macOS"
S=$(stage "qatindex-macos-v$VERSION")
cat > "$S/Launch QAT Index.command" <<'CMD'
#!/usr/bin/env bash
HERE="$(cd "$(dirname "$0")" && pwd)"
open "$HERE/app/index.html"
CMD
chmod +x "$S/Launch QAT Index.command"
cat > "$S/PLATFORM_INSTALL.md" <<EOF
# QAT Command Index — macOS

## Quick start
1. Unzip this archive.
2. Double-click **Launch QAT Index.command**.
   (Right-click → Open the first time, to bypass Gatekeeper.)

## Install as a Mac app (recommended)
- **Safari 17+**: open https://socrtwo.github.io/qatindex-SF/, then **File → Add to Dock**.
- **Chrome / Edge / Arc**: open the URL, click the install button in the address bar.

The installed app runs in its own window, supports offline use, and shows up in
Spotlight, the Dock, and Launchpad like any native macOS application.

Version: $VERSION
EOF
pkg_zip "qatindex-macos-v$VERSION" "$S"

# ----------------------------------------------------------------------
# Linux
# ----------------------------------------------------------------------
echo "▶ Linux"
S=$(stage "qatindex-linux-v$VERSION")
cat > "$S/launch-qat-index.sh" <<'SH'
#!/usr/bin/env bash
HERE="$(cd "$(dirname "$0")" && pwd)"
URL="file://$HERE/app/index.html"
if   command -v xdg-open >/dev/null 2>&1; then xdg-open "$URL"
elif command -v gio      >/dev/null 2>&1; then gio open "$URL"
elif command -v firefox  >/dev/null 2>&1; then firefox  "$URL"
elif command -v chromium >/dev/null 2>&1; then chromium "$URL"
else echo "Open this URL in your browser: $URL"; fi
SH
chmod +x "$S/launch-qat-index.sh"
cat > "$S/qat-index.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=QAT Command Index
Comment=Searchable index of Microsoft Office QAT and ribbon command identifiers
Exec=bash -c "\$(dirname %k)/launch-qat-index.sh"
Icon=office
Terminal=false
Categories=Office;Utility;Development;
EOF
cat > "$S/PLATFORM_INSTALL.md" <<EOF
# QAT Command Index — Linux

## Quick start
1. Extract: \`tar -xzf qatindex-linux-v$VERSION.tar.gz\`
2. Run: \`./qatindex-linux-v$VERSION/launch-qat-index.sh\`

## Install a desktop entry
\`\`\`bash
DEST="\$HOME/.local/share/qat-index"
mkdir -p "\$DEST"
cp -r qatindex-linux-v$VERSION/* "\$DEST/"
sed -i "s|Exec=.*|Exec=bash \$DEST/launch-qat-index.sh|" "\$DEST/qat-index.desktop"
desktop-file-install --dir="\$HOME/.local/share/applications" "\$DEST/qat-index.desktop"
\`\`\`

## Install as a real Linux app (recommended)
Open https://socrtwo.github.io/qatindex-SF/ in **Chrome / Chromium /
Brave / Edge** and click the install button in the address bar. The PWA
integrates with your application launcher and works offline.

Version: $VERSION
EOF
pkg_tgz "qatindex-linux-v$VERSION" "$S"

# ----------------------------------------------------------------------
# ChromeOS
# ----------------------------------------------------------------------
echo "▶ ChromeOS"
S=$(stage "qatindex-chromeos-v$VERSION")
cat > "$S/PLATFORM_INSTALL.md" <<EOF
# QAT Command Index — ChromeOS

ChromeOS treats PWAs as first-class apps — no APK, no extension required.

## Install (recommended)
1. Open https://socrtwo.github.io/qatindex-SF/ in Chrome.
2. Click ⋮ → **Install QAT Command Index** (or the install icon in the address bar).
3. The app appears in your launcher (search "QAT Index") and works offline.

## Run from this bundle (no internet)
1. Unzip the archive into Files → My files.
2. Open **app/index.html** in Chrome (right-click → Open with → Chrome).

## Power users
The included \`app/\` directory is the full PWA. To self-host on a Chromebook
running Linux apps, drop \`app/\` into any static web server (e.g. \`python3
-m http.server\`) and visit it from Chrome.

Version: $VERSION
EOF
pkg_zip "qatindex-chromeos-v$VERSION" "$S"

# ----------------------------------------------------------------------
# Android
# ----------------------------------------------------------------------
echo "▶ Android"
S=$(stage "qatindex-android-v$VERSION")
cat > "$S/PLATFORM_INSTALL.md" <<EOF
# QAT Command Index — Android

## Install (recommended)
1. Open https://socrtwo.github.io/qatindex-SF/ in **Chrome** for Android.
2. Tap ⋮ → **Install app** (or "Add to Home screen").
3. The app installs like any other Android app: launcher icon, splash screen,
   no browser chrome, and offline support.

## Build your own APK (optional, advanced)
The PWA can be wrapped as a real Android Package via Google's
[PWABuilder](https://www.pwabuilder.com/):

1. Visit https://www.pwabuilder.com/
2. Enter the URL: \`https://socrtwo.github.io/qatindex-SF/\`
3. Click **Package for stores → Android → Generate Package**.
4. PWABuilder produces a signed APK / AAB you can sideload or upload to Play.

This bundle ships the unwrapped PWA in \`app/\` for reference and offline use.

Version: $VERSION
EOF
pkg_zip "qatindex-android-v$VERSION" "$S"

# ----------------------------------------------------------------------
# iOS / iPadOS
# ----------------------------------------------------------------------
echo "▶ iOS"
S=$(stage "qatindex-ios-v$VERSION")
cat > "$S/PLATFORM_INSTALL.md" <<EOF
# QAT Command Index — iOS / iPadOS

iOS does not allow third-party app stores or sideloading without Xcode + an
Apple Developer account. The PWA is the recommended distribution channel.

## Install (recommended)
1. Open https://socrtwo.github.io/qatindex-SF/ in **Safari** (this
   does not work in Chrome on iOS — Apple restricts PWA install to Safari).
2. Tap the **Share** button.
3. Tap **Add to Home Screen**.
4. The app appears on your Home Screen, runs in standalone mode, and works
   offline (cached service worker).

## Build a native IPA (optional, advanced)
- Use [Capacitor](https://capacitorjs.com/) to wrap the \`app/\` directory in
  this bundle and produce a real iOS app via Xcode.
- An Apple Developer Program membership (\$99/yr) is required to sign and
  distribute outside TestFlight.

Version: $VERSION
EOF
pkg_zip "qatindex-ios-v$VERSION" "$S"

# ----------------------------------------------------------------------
# Web (hosted)
# ----------------------------------------------------------------------
echo "▶ Web"
S=$(stage "qatindex-web-v$VERSION")
cat > "$S/PLATFORM_INSTALL.md" <<EOF
# QAT Command Index — Web

## Use without installing
Open https://socrtwo.github.io/qatindex-SF/ in any modern browser.

## Self-host
Drop the contents of \`app/\` into any static web server (Apache, nginx,
GitHub Pages, Netlify, Cloudflare Pages, Vercel, S3 + CloudFront…).

\`\`\`bash
cd app
python3 -m http.server 8080
# visit http://localhost:8080
\`\`\`

The app is client-side — the command-identifier data is fetched from
Microsoft's official OfficeDev repository on demand.

Version: $VERSION
EOF
pkg_zip "qatindex-web-v$VERSION" "$S"

# ----------------------------------------------------------------------
# Cleanup + checksums + release notes
# ----------------------------------------------------------------------
rm -rf "$DIST/_stage"

# Generate SHA-256 checksums for every bundle so downloads can be verified.
echo "▶ SHA256SUMS"
( cd "$DIST" && sha256sum *.zip *.tar.gz 2>/dev/null > SHA256SUMS )
cat "$DIST/SHA256SUMS"

cat > "$DIST/RELEASE_NOTES.md" <<EOF
# QAT Command Index — v$VERSION

A modern, searchable index of Quick Access Toolbar (QAT) and ribbon command
identifiers for Microsoft Office. The same PWA codebase runs everywhere.

## 📦 Downloads

| Platform | Bundle | What's inside |
|----------|--------|---------------|
| 🪟 Windows           | \`qatindex-windows-v$VERSION.zip\`         | PWA + .bat launcher |
| 🍎 macOS             | \`qatindex-macos-v$VERSION.zip\`           | PWA + .command launcher |
| 🐧 Linux             | \`qatindex-linux-v$VERSION.tar.gz\`        | PWA + .sh launcher + .desktop |
| 🟢 ChromeOS          | \`qatindex-chromeos-v$VERSION.zip\`        | PWA + install instructions |
| 🤖 Android           | \`qatindex-android-v$VERSION.zip\`         | PWA + APK build instructions |
| 📱 iOS / iPadOS      | \`qatindex-ios-v$VERSION.zip\`             | PWA + iOS install instructions |
| 🌐 Web (hosted)      | \`qatindex-web-v$VERSION.zip\`             | PWA static site for self-hosting |

Verify any download against \`SHA256SUMS\` (e.g. \`sha256sum -c SHA256SUMS\`).

The hosted web app lives at <https://socrtwo.github.io/qatindex-SF/> —
on every supported platform you can install it directly from your browser
(no download required).

EOF

echo
echo "✅ Built bundles in $DIST:"
ls -lh "$DIST"
