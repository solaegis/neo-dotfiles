#!/usr/bin/env bash
# Build ~/Applications/Cursor Omnicom.app + ~/bin/cursor-omnicom for the
# Userdata Switcher managed Omnicom userdata.
#
# On macOS Tahoe, shell-script .app bundles get icon-jailed and Dock-unreliable.
# The Dock app is a Mach-O Swift stub + Liquid Glass Assets.car (via actool).
set -euo pipefail

APP_NAME="Cursor Omnicom"
APP_DIR="${HOME}/Applications/${APP_NAME}.app"
BUNDLE_ID="com.solaegis.cursor.omnicom"
CURSOR_BIN="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
CURSOR_ICNS="/Applications/Cursor.app/Contents/Resources/Cursor.icns"
USER_DATA_DIR="${HOME}/Library/Application Support/udsw/cursor/u/omnicom"
EXTENSIONS_DIR="${HOME}/.cursor/extensions"
BIN_OUT="${HOME}/bin/cursor-omnicom"
ACTOOL="${ACTOOL:-/Applications/Xcode.app/Contents/Developer/usr/bin/actool}"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if [[ ! -x "${CURSOR_BIN}" ]]; then
  echo "error: Cursor CLI not found at ${CURSOR_BIN}" >&2
  exit 1
fi
if [[ ! -f "${CURSOR_ICNS}" ]]; then
  echo "error: Cursor icon not found at ${CURSOR_ICNS}" >&2
  exit 1
fi
if ! command -v swiftc >/dev/null 2>&1; then
  echo "error: swiftc not found (Xcode / CLT required)" >&2
  exit 1
fi
if [[ ! -x "${ACTOOL}" ]]; then
  echo "error: actool not found at ${ACTOOL} (full Xcode required for Tahoe icons)" >&2
  exit 1
fi

mkdir -p "${HOME}/Applications" "${HOME}/bin"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/cursor-omnicom.XXXXXX")"
cleanup() { rm -rf "${TMP}"; }
trap cleanup EXIT

PATH_PREFIX='/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/share/google-cloud-sdk/bin:${HOME}/Library/Application Support/reflex/bun/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
PATH_PREFIX_EXPANDED="/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/share/google-cloud-sdk/bin:${HOME}/Library/Application Support/reflex/bun/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# --- CLI (bash is fine for terminal use) --------------------------------------
cat >"${BIN_OUT}" <<EOF
#!/usr/bin/env bash
# Launch Cursor with Userdata Switcher Omnicom userdata.
set -euo pipefail
USER_DATA_DIR="\${HOME}/Library/Application Support/udsw/cursor/u/omnicom"
EXTENSIONS_DIR="\${HOME}/.cursor/extensions"
CURSOR_BIN="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"

if [[ ! -x "\${CURSOR_BIN}" ]]; then
  echo "error: Cursor CLI not found at \${CURSOR_BIN}" >&2
  exit 1
fi

# GUI/Dock launches omit Homebrew; MCP stdio plugins need npx/bun/gcloud on PATH.
export PATH="${PATH_PREFIX}\${PATH:+:\${PATH}}"

exec "\${CURSOR_BIN}" \\
  --user-data-dir "\${USER_DATA_DIR}" \\
  --extensions-dir "\${EXTENSIONS_DIR}" \\
  "\$@"
EOF
chmod +x "${BIN_OUT}"

# --- App bundle ---------------------------------------------------------------
rm -rf "${APP_DIR}"
mkdir -p \
  "${APP_DIR}/Contents/MacOS" \
  "${APP_DIR}/Contents/Resources"

EXEC_NAME="Cursor Omnicom"

# Mach-O launcher (Tahoe rejects script-based .app icons / Dock reliability)
cat >"${TMP}/launcher.swift" <<'SWIFT'
import Foundation

let home = FileManager.default.homeDirectoryForCurrentUser.path
let userDataDir = "\(home)/Library/Application Support/udsw/cursor/u/omnicom"
let extensionsDir = "\(home)/.cursor/extensions"
let cursorBin = "/Applications/Cursor.app/Contents/Resources/app/bin/cursor"

var env = ProcessInfo.processInfo.environment
let pathPrefix =
  "/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/share/google-cloud-sdk/bin:"
  + "\(home)/Library/Application Support/reflex/bun/bin:\(home)/bin:"
  + "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
if let existing = env["PATH"], !existing.isEmpty {
  env["PATH"] = pathPrefix + ":" + existing
} else {
  env["PATH"] = pathPrefix
}

guard FileManager.default.isExecutableFile(atPath: cursorBin) else {
  fputs("error: Cursor CLI not found at \(cursorBin)\n", stderr)
  exit(1)
}

var argv = [cursorBin, "--user-data-dir", userDataDir, "--extensions-dir", extensionsDir]
argv.append(contentsOf: CommandLine.arguments.dropFirst())

let cArgs = argv.map { strdup($0) } + [nil]
defer { cArgs.forEach { free($0) } }
let cEnv = env.map { strdup("\($0.key)=\($0.value)") } + [nil]
defer { cEnv.forEach { free($0) } }

execve(cursorBin, cArgs, cEnv)
fputs("error: execve failed: \(String(cString: strerror(errno)))\n", stderr)
exit(127)
SWIFT
swiftc -O -o "${APP_DIR}/Contents/MacOS/${EXEC_NAME}" "${TMP}/launcher.swift"
chmod +x "${APP_DIR}/Contents/MacOS/${EXEC_NAME}"

cat >"${APP_DIR}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${EXEC_NAME}</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIconName</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.1.2</string>
  <key>CFBundleVersion</key>
  <string>4</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>LSEnvironment</key>
  <dict>
    <key>PATH</key>
    <string>${PATH_PREFIX_EXPANDED}</string>
  </dict>
  <key>CFBundleDocumentTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeName</key>
      <string>Folder</string>
      <key>CFBundleTypeRole</key>
      <string>Viewer</string>
      <key>LSHandlerRank</key>
      <string>Alternate</string>
      <key>LSItemContentTypes</key>
      <array>
        <string>public.folder</string>
        <string>public.item</string>
        <string>public.data</string>
      </array>
    </dict>
  </array>
</dict>
</plist>
EOF

# --- Badged icon (Cursor + O, inset for squircle safe area) -------------------
BASE_PNG="${TMP}/cursor-base.png"
BADGED_PNG="${TMP}/cursor-badged.png"
sips -s format png "${CURSOR_ICNS}" --out "${BASE_PNG}" >/dev/null

cat >"${TMP}/badge.swift" <<'SWIFT'
import AppKit
import Foundation

guard CommandLine.arguments.count >= 3 else {
  fputs("usage: badge <in.png> <out.png>\n", stderr)
  exit(1)
}
let inURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outURL = URL(fileURLWithPath: CommandLine.arguments[2])
guard let base = NSImage(contentsOf: inURL) else {
  fputs("failed to load base image\n", stderr)
  exit(1)
}
let pixelSize = NSSize(width: 1024, height: 1024)
let out = NSImage(size: pixelSize)
out.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high

// Full-bleed Cursor base (same as Acxiom). Keep the O badge inside the
// squircle safe zone — macOS corner radius clips ~10% of a corner-flush badge.
base.draw(
  in: NSRect(origin: .zero, size: pixelSize),
  from: .zero,
  operation: .sourceOver,
  fraction: 1.0
)

// Match Acxiom's post-actool safe footprint (badge ends ~15% in from edges).
let badgeSide = pixelSize.width * 0.28
let margin = pixelSize.width * 0.18
let badgeRect = NSRect(
  x: pixelSize.width - badgeSide - margin,
  y: margin,
  width: badgeSide,
  height: badgeSide
)
let badgePath = NSBezierPath(ovalIn: badgeRect)
NSColor(calibratedRed: 0.72, green: 0.28, blue: 0.08, alpha: 1.0).setFill()
badgePath.fill()
NSColor.white.withAlphaComponent(0.9).setStroke()
badgePath.lineWidth = max(2.0, pixelSize.width * 0.008)
badgePath.stroke()

let label = "O" as NSString
let font = NSFont.boldSystemFont(ofSize: badgeSide * 0.55)
let attrs: [NSAttributedString.Key: Any] = [
  .font: font,
  .foregroundColor: NSColor.white
]
let textSize = label.size(withAttributes: attrs)
let textOrigin = NSPoint(
  x: badgeRect.midX - textSize.width / 2.0,
  y: badgeRect.midY - textSize.height / 2.0
)
label.draw(at: textOrigin, withAttributes: attrs)
out.unlockFocus()

guard let tiff = out.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
  fputs("failed to encode PNG\n", stderr)
  exit(1)
}
try png.write(to: outURL)
SWIFT
swiftc -O -o "${TMP}/badge" "${TMP}/badge.swift"
"${TMP}/badge" "${BASE_PNG}" "${BADGED_PNG}"

# Liquid Glass .icon → Assets.car + legacy AppIcon.icns (Tahoe needs IconImageStack)
ICON_DIR="${TMP}/AppIcon.icon"
mkdir -p "${ICON_DIR}/Assets"
cp "${BADGED_PNG}" "${ICON_DIR}/Assets/logo.png"
cat >"${ICON_DIR}/icon.json" <<'JSON'
{
  "fill" : {
    "automatic-gradient" : "display-p3:0.05000,0.05000,0.07000,1.00000"
  },
  "groups" : [
    {
      "layers" : [
        {
          "glass" : false,
          "image-name" : "logo.png",
          "name" : "Logo",
          "position" : {
            "scale" : 0.65,
            "translation-in-points" : [0, 0]
          }
        }
      ],
      "lighting" : "combined",
      "shadow" : {
        "kind" : "neutral",
        "opacity" : 0.3
      },
      "specular" : true,
      "translucency" : {
        "enabled" : false,
        "value" : 0.0
      },
      "name" : "Group"
    }
  ],
  "supported-platforms" : {
    "squares" : ["macOS"]
  }
}
JSON

ICON_OUT="${TMP}/icon-out"
mkdir -p "${ICON_OUT}"
"${ACTOOL}" "${ICON_DIR}" --compile "${ICON_OUT}" \
  --platform macosx --minimum-deployment-target 15.0 \
  --app-icon AppIcon --include-all-app-icons \
  --enable-icon-stack-fallback-generation disabled \
  --output-partial-info-plist "${ICON_OUT}/partial.plist" >/dev/null

cp "${ICON_OUT}/Assets.car" "${APP_DIR}/Contents/Resources/Assets.car"
cp "${ICON_OUT}/AppIcon.icns" "${APP_DIR}/Contents/Resources/AppIcon.icns"

echo -n 'APPL????' >"${APP_DIR}/Contents/PkgInfo"

xattr -cr "${APP_DIR}" 2>/dev/null || true
codesign --force --deep --sign - "${APP_DIR}"

if [[ -x "${LSREGISTER}" ]]; then
  "${LSREGISTER}" -f "${APP_DIR}"
fi

echo "Installed: ${APP_DIR}"
echo "Installed: ${BIN_OUT}"
echo "Userdata:  ${USER_DATA_DIR}"
echo "Drag \"${APP_NAME}\" from ~/Applications to the Dock if it is not already pinned."
echo "If the Dock tile still looks stale: killall Dock"
