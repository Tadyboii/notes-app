# Notes App

A Flutter notes application built with clean architecture, BLoC state management, and local storage using Hive.

## Features

### 📝 Create & Edit Notes
<img src="https://github.com/Tadyboii/notes-app/blob/bd2ece1f14b08577c557b3347e656336ae89c24d/demo3.gif" height="500">

Create new notes with a clean, distraction-free interface. Edit existing notes with real-time updates.

### 🔄 Update Notes
<img src="https://github.com/Tadyboii/notes-app/blob/bd2ece1f14b08577c557b3347e656336ae89c24d/demo4.gif" height="500">

Seamlessly update your notes with instant feedback.

### 🔍 Search Notes
<img src="https://github.com/Tadyboii/notes-app/blob/bd2ece1f14b08577c557b3347e656336ae89c24d/demo2.gif" height="500">

Quickly find any note with the search functionality.

### 🗑️ Delete Notes
<img src="https://github.com/Tadyboii/notes-app/blob/bd2ece1f14b08577c557b3347e656336ae89c24d/demo1.gif" height="500">

Remove notes with confirmation dialog to prevent accidental deletions.

## Architecture

This project follows **Clean Architecture** principles with the following layers:

- **Presentation Layer**: BLoC pattern for state management
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Repository pattern with Hive local database

## Tech Stack

### State Management
- **flutter_bloc** - Predictable state management using BLoC pattern
- **bloc** - Core BLoC library

### Local Database
- **hive** - Lightweight and fast NoSQL database
- **hive_flutter** - Hive integration for Flutter

### Dependency Injection
- **get_it** - Service locator for dependency injection
- **injectable** - Code generation for get_it

### Code Generation
- **freezed** - Code generation for immutable classes
- **json_serializable** - JSON serialization/deserialization
- **build_runner** - Build system for Dart code generation

### Development Tools
- **very_good_analysis** - Strict linting rules
- **fvm** - Flutter Version Management

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- FVM (optional but recommended)

### Installation

1. Clone the repository:
git clone https://github.com/Tadyboii/notes-app.git
cd notes-app

2. Install dependencies:
flutter pub get

3. Generate code:
dart run build_runner build --delete-conflicting-outputs

### Running the App

Run the app in development mode:
flutter run --target lib/main_development.dart

Or using a specific device:
flutter run --target lib/main_development.dart -d <device-id>

### Building the App

For Android:
```bash
flutter build apk --target lib/main_development.dart
```
For iOS:
```bash
flutter build ios --target lib/main_development.dart
```
For Web:
```bash
flutter build web --target lib/main_development.dart
```
## Project Structure

lib/
├── app/              # App configuration and routing
├── core/             # Core utilities and dependency injection
│   └── di/          # Dependency injection setup
├── features/         # Feature modules
│   └── notes_list/  # Notes feature
│       ├── data/    # Data sources and repositories
│       ├── domain/  # Entities and use cases
│       └── presentation/ # UI and BLoC
└── main_development.dart # Development entry point

## Code Generation

When you modify Freezed or Injectable annotations, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```
For continuous code generation during development:
```bash
dart run build_runner watch --delete-conflicting-outputs
```
## Testing

Run all tests:
```bash
flutter test
```
Run tests with coverage:
```bash
flutter test --coverage
```
## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
