# Flutter Lab 8-9



## Overview


This Flutter lab demonstrates how to access various hardware features, including:

 Camera (for capturing images and videos)

 QR Code Scanning

 GPS (Google Maps API integration)

 Bluetooth Connectivity

 Audio Recording

Accelerometer (motion detection)

 Google Sign-In Authentication

## Prerequisites

Before running the project, ensure you have:

Flutter SDK installed ([Download here](https://docs.flutter.dev/get-started/install))

A configured Android/iOS device or emulator

Necessary API keys for Google services (Google Maps API, Google Sign-In)

Permissions enabled for camera, microphone, location, and Bluetooth

## Dependencies

Add the following dependencies to your pubspec.yaml:
```javascript
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+2
  qr_code_scanner: ^1.0.1
  google_maps_flutter: ^2.2.5
  location: ^5.0.3
  flutter_blue_plus: ^1.20.2
  permission_handler: ^11.0.1
  audioplayers: ^5.2.1
  sensors_plus: ^3.0.4
  google_sign_in: ^6.2.1
  firebase_auth: ^4.15.2
  firebase_core: ^2.20.0
```

## Running the Project
Run the following command:
``` bash
flutter run
```
