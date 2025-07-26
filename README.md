# Keyboard Clean Tool

A macOS utility app that temporarily blocks keyboard input to facilitate
keyboard cleaning without accidentally triggering system shortcuts or typing
unwanted characters.

## Features

- **Keyboard Input Blocking**: Temporarily blocks all keyboard input using macOS
keyboard accessibility APIs
- **Permission Management**: Automatic accessibility permission requests
- **Modern UI**: Clean, intuitive SwiftUI interface

## Requirements

- macOS 15.0 or later
- Accessibility permissions (granted through System Settings)

## Installation

1. Clone or download this repository
2. Open the project in Xcode (`open "keyboard cleaning tool.xcodeproj"`)
3. Build and run the project (⌘+R)
4. Grant accessibility permissions when prompted

## Usage

### First Time Setup

1. Launch the app
2. When prompted, go to System Settings > Privacy & Security > Accessibility
3. Enable the checkbox for "Keyboard Clean Tool"
4. Return to the app and try locking the keyboard

### Using the App

1. **Lock Keyboard**: Click the "Lock Keyboard" button to start blocking input
2. **Clean**: Use this time to clean your keyboard without triggering shortcuts
3. **Unlock**: Click "Unlock Keyboard" or wait for the timer to expire

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **CoreGraphics**: Keyboard event interception via CGEventTap
- **AppKit**: Status bar integration and system permissions
- **ObservableObject**: Reactive state management

### Key Components

- `KeyboardBlockingService`: Handles keyboard event blocking
- `ContentView`: Main UI with timer and controls
- `AppDelegate`: App lifecycle

### Security

- Requires accessibility permissions for keyboard event interception
- App sandboxing disabled for accessibility functionality
- Automatic permission requests with user guidance

## Development

### Building from Source

1. Ensure you have Xcode 14.0 or later
2. Open `keyboard_cleaning_tool.xcodeproj`
3. Select your target device/simulator
4. Build and run (⌘+R)

### Project Structure

```txt
keyboard_cleaning_tool/
├── keyboard_cleaning_toolApp.swift     # Main app entry point
├── ContentView.swift                   # Main UI
├── KeyboardBlockingService.SwiftUI     # Keyboard blocking logic
├── keyboard_cleaning_tool.entitlements # App permissions
└── Assets.xcassets/                    # App icons and assets
```

## Troubleshooting

### Permission Issues

If the app doesn't work after granting permissions:

1. Go to System Settings > Privacy & Security > Accessibility
2. Remove the app from the list
3. Re-add it by clicking the "+" button and selecting the app
4. Restart the app

### App Not Responding

If the keyboard remains locked:

1. Use the status bar menu to open the app
2. Click "Unlock Keyboard"
3. If that doesn't work, force quit the app (⌘+Option+Esc)

## License

This project is open source and available under the [GPLv3 License](LICENSE).

## Contributing

Feel free to submit issues and enhancement requests!
