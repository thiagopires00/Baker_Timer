
# Dough Timer App

A specialized dough timer app designed for bakers to manage multiple types of dough with precision. This app provides configurable timers to manage dough mixing processes effectively.

---

## Features

- **Customizable Dough Types**: Add, edit, and delete dough types with specific speed and timing configurations.
- **Simultaneous Timers**: Manage multiple timers for different dough types on a single screen.
- **Audio Alerts**: Notify users with audio alerts when the timer ends.
- **Adjustable Timing**: Add an extra minute or acknowledge the alert directly from the timer interface.
- **Test Sound**: Play and stop the alarm sound to test audio settings.
- **User-friendly Interface**: Built with a clean, intuitive design for ease of use.

---

## Installation

### Prerequisites

- **Flutter**: Ensure you have Flutter installed on your machine. Follow [Flutter installation instructions](https://docs.flutter.dev/get-started/install).
- **Android SDK**: Install the Android SDK for building and testing on Android devices.
- **Xcode** (optional): For building and testing on iOS devices.

### Clone the Repository

\`\`\`bash
git clone https://github.com/thiagopires00/dough_timer_app.git
cd dough_timer_app
\`\`\`

### Install Dependencies

Run the following command to install Flutter dependencies:

\`\`\`bash
flutter pub get
\`\`\`

---

## Running the App

### On Android Emulator or Physical Device

1. Connect your Android device or start an emulator.
2. Run the app:
   \`\`\`bash
   flutter run
   \`\`\`

### On iOS Simulator or Device

1. Open the project in Xcode if building for iOS:
   \`\`\`bash
   open ios/Runner.xcworkspace
   \`\`\`
2. Configure the signing settings in Xcode.
3. Run the app:
   \`\`\`bash
   flutter run
   \`\`\`

---

## Building Release APK

To generate a release APK for Android:

\`\`\`bash
flutter build apk --release
\`\`\`

You can find the APK file in the \`build/app/outputs/flutter-apk/\` directory.

## Screenshots
---
<img width="1070" alt="Screenshot 2024-11-14 at 11 14 15 PM" src="https://github.com/user-attachments/assets/db6e97d7-a635-4f0a-a3f8-20a05e8c8cd0">
<img width="1070" alt="Screenshot 2024-11-14 at 11 14 20 PM" src="https://github.com/user-attachments/assets/e194e58f-1e59-4148-82c4-37d9aa317be7">
<img width="1070" alt="Screenshot 2024-11-14 at 11 14 27 PM" src="https://github.com/user-attachments/assets/cdaf759a-94f9-48ed-ad58-1f04e3e0efc7">





---

## Folder Structure

\`\`\`plaintext
dough_timer_app/
├── android/       # Android-specific configuration
├── ios/           # iOS-specific configuration
├── lib/           # Flutter source code
│   ├── main.dart  # App entry point
│   ├── models/    # Data models
│   ├── screens/   # App screens
│   └── widgets/   # Reusable UI components
├── assets/        # Audio and image assets
├── pubspec.yaml   # Flutter dependencies
└── README.md      # Project information
\`\`\`

---

## Contributing

Contributions are welcome! If you'd like to contribute to this project:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request for review.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

**Thiago Pires**  
Passionate baker and software developer creating tools to improve the baking process.

---
EOL
