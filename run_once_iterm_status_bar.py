#!/usr/bin/env python3
"""
Configure iTerm2 status bar with a development-friendly set of components.

Run once (e.g. after chezmoi apply). Updates the iTerm2 preferences plist
that iTerm actually loads (custom folder if set, else ~/Library/Preferences).

Components added (left to right):
  - User name
  - Host name
  - Current directory
  - Git state (branch, dirty, ahead/behind)
  - Job name (foreground process)
  - [spacer]
  - CPU utilization (graph)
  - Memory utilization (graph)
  - [spacer]
  - Clock

Requires: iTerm2, Python 3, plist at the path iTerm loads from.
"""
from __future__ import annotations

import os
import plistlib
import sys
from pathlib import Path

# Keys from iTerm2 source (iTermStatusBarLayout.m, iTermStatusBarComponent.m)
LAYOUT_KEY_COMPONENTS = "components"
LAYOUT_KEY_ADVANCED = "advanced configuration"
CONFIG_KEY_KNOWS = "knobs"
CONFIG_KEY_LAYOUT_ADVANCED = "layout advanced configuration dictionary value"

# Base knobs (iTermStatusBarBaseComponent)
KNOB_PRIORITY = "base: priority"
KNOB_COMPRESSION = "base: compression resistance"
KNOB_MAX_WIDTH = "maxwidth"
KNOB_MIN_WIDTH = "minwidth"

# Fixed spacer (default width 5)
FIXED_SPACER_WIDTH_KEY = "iTermStatusBarFixedSpacerComponentWidthKnob"

# Clock (default format "M-DD h:mm")
CLOCK_FORMAT_KEY = "format"

# Git (polling interval in seconds; default 2)
GIT_POLLING_KEY = "iTermStatusBarGitComponentPollingIntervalKey"


def default_knobs(priority: int = 5) -> dict:
    # Use large max width; plist doesn't serialize float('inf') portably
    return {
        KNOB_PRIORITY: priority,
        KNOB_COMPRESSION: 1,
        KNOB_MAX_WIDTH: 10000,
        KNOB_MIN_WIDTH: 0,
    }


def component(class_name: str, knobs: dict | None = None) -> dict:
    return {
        "class": class_name,
        "configuration": {
            CONFIG_KEY_KNOWS: knobs if knobs is not None else default_knobs(),
        },
    }


def development_status_bar_components() -> list[dict]:
    return [
        component("iTermStatusBarUsernameComponent"),
        component("iTermStatusBarHostnameComponent"),
        component("iTermStatusBarWorkingDirectoryComponent"),
        component("iTermStatusBarGitComponent", {
            **default_knobs(),
            GIT_POLLING_KEY: 2,
        }),
        component("iTermStatusBarJobComponent"),
        component("iTermStatusBarFixedSpacerComponent", {
            **default_knobs(),
            FIXED_SPACER_WIDTH_KEY: 8,
        }),
        component("iTermStatusBarCPUUtilizationComponent"),
        component("iTermStatusBarMemoryUtilizationComponent"),
        component("iTermStatusBarFixedSpacerComponent", {
            **default_knobs(),
            FIXED_SPACER_WIDTH_KEY: 8,
        }),
        component("iTermStatusBarClockComponent", {
            **default_knobs(),
            CLOCK_FORMAT_KEY: "M-d HH:mm",
        }),
    ]


def iterm_plist_path() -> tuple[Path, bool]:
    """Return (plist path iTerm2 loads from, True if custom folder e.g. iCloud)."""
    prefs_plist = Path.home() / "Library/Preferences/com.googlecode.iterm2.plist"
    if prefs_plist.exists():
        try:
            with open(prefs_plist, "rb") as f:
                prefs = plistlib.load(f)
            if prefs.get("LoadPrefsFromCustomFolder") and prefs.get("PrefsCustomFolder"):
                # Expand only leading ~ (home); leave literal ~ in path (e.g. com~apple~CloudDocs)
                folder = Path(os.path.expanduser(prefs["PrefsCustomFolder"]))
                custom = folder / "com.googlecode.iterm2.plist"
                return (custom, True)
        except Exception:
            pass
    return (prefs_plist, False)


def main() -> int:
    path, is_custom = iterm_plist_path()
    if not path.exists():
        if is_custom:
            print(
                "iTerm is set to load prefs from a custom folder (e.g. iCloud), but that file was not found.",
                file=sys.stderr,
            )
            print(f"Path: {path}", file=sys.stderr)
            print(
                "Run this script when the file is available (e.g. iCloud synced, or after opening iTerm so it can create/sync the file).",
                file=sys.stderr,
            )
        else:
            print(f"iTerm prefs not found: {path}", file=sys.stderr)
        return 1

    with open(path, "rb") as f:
        prefs = plistlib.load(f)

    bookmarks = prefs.get("New Bookmarks")
    if not bookmarks:
        print("No profiles in iTerm prefs.", file=sys.stderr)
        return 1

    # Update first profile's status bar layout
    profile = bookmarks[0]
    if "Status Bar Layout" not in profile:
        profile["Status Bar Layout"] = {LAYOUT_KEY_COMPONENTS: [], LAYOUT_KEY_ADVANCED: {}}
    layout = profile["Status Bar Layout"]
    if not isinstance(layout.get(LAYOUT_KEY_ADVANCED), dict):
        layout[LAYOUT_KEY_ADVANCED] = layout.get(LAYOUT_KEY_ADVANCED) or {}

    layout[LAYOUT_KEY_COMPONENTS] = development_status_bar_components()
    profile["Show Status Bar"] = True

    with open(path, "wb") as f:
        plistlib.dump(prefs, f, sort_keys=False)

    print(f"Updated status bar for profile '{profile.get('Name', 'Default')}' at {path}")
    print("Restart iTerm2 or open a new window for changes to take effect.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
