# Press Here

A Flutter interactive game inspired by the children's book concept. Manipulate colorful dots through taps, swipes, shakes, and tilts.

## Features

- **Tap** - Create new dots near existing ones
- **Multi-tap** - Spawn dots in a circular pattern
- **Long press** - Grow a dot's size
- **Swipe** - Cycle through colors (yellow, red, blue)
- **Shake device** - Scatter all dots randomly
- **Tilt device** - Apply gravity to move dots

## Requirements

- Flutter 3.38.5+
- Dart 3.10.4+
- Android SDK
- PocketBase backend (for authentication)
- Google OAuth credentials

## Setup

1. Install dependencies:

   ```sh
   make deps
   ```

2. Create a `.env` file with your Google OAuth client ID:

   ```
   GOOGLE_CLIENT_ID=your-client-id-here
   ```

3. Configure PocketBase:
   - Production: `https://admin.geoffjay.com`
   - Development: `http://127.0.0.1:8090`

## Development

```sh
# Run in debug mode (local backend)
make run

# Run in release mode (production backend)
make run-release

# Build debug APK
make build-debug

# Build release APK
make build

# Run tests
make test

# Static analysis
make analyze
```

## Tech Stack

- **Framework**: Flutter/Dart
- **State Management**: Provider
- **Navigation**: GoRouter
- **Backend**: PocketBase
- **Auth**: Google Sign-In
- **Sensors**: sensors_plus (accelerometer/gyroscope)

## License

MIT
