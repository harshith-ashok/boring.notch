# Boring Notch Custom Changes

This fork adds two local integrations:

1. Voice listening state
2. Device status shelf

## Voice Listening State

The notch reads `/Users/harshith/.status.json` and uses it in two places:

- The inactive animated face
- The left side of the expanded notch header

Expected file format:

```json
{
  "is_listening": true
}
```

The real writer for this file lives outside this repo in your external voice assistant project.

## Device Status Shelf

The `Shelf` tab no longer shows the file drop / quick share UI.

Instead, it reads `/Users/harshith/.device_state.json` and shows cards for:

- `Main Light`
- `Ceiling Fan`
- `Accent Light`

Expected file format:

```json
{
  "devices": {
    "Main Light": { "status": 0 },
    "Ceiling Fan": { "status": 1, "value": 5 },
    "Accent Light": { "status": 1, "color": "green" }
  }
}
```

## Important Note

For these direct file reads to work, App Sandbox must be disabled for local testing. In this project that is currently done in the Xcode build settings.

## Main Files Changed

- `/Users/harshith/Dev/Projects/boring_notch/boringNotch/managers/VoiceAssistantStateManager.swift`
- `/Users/harshith/Dev/Projects/boring_notch/boringNotch/components/Notch/BoringHeader.swift`
- `/Users/harshith/Dev/Projects/boring_notch/boringNotch/components/AnimatedFace.swift`
- `/Users/harshith/Dev/Projects/boring_notch/boringNotch/ContentView.swift`
- `/Users/harshith/Dev/Projects/boring_notch/boringNotch/components/Shelf/Views/ShelfView.swift`
