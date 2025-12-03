# Freeway Control Panel

A Flutter control panel for managing the Freeway AI Gateway.

## Features

- **Dashboard**: View service stats, selected models, and quick metrics
- **Models**: Browse all available free and paid OpenRouter models
- **Projects**: Create, edit, and manage projects with API keys
- **Settings**: Configure API connection and theme preferences
- **Responsive**: Works on mobile, tablet, and desktop
- **Themes**: Light and dark mode with system preference support

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- A running Freeway instance

### Installation

```bash
# Navigate to project
cd control_plane

# Get dependencies
flutter pub get

# Run on your platform
flutter run -d windows  # or macos, linux, chrome, etc.
```

### Configuration

1. Launch the app
2. Go to **Settings**
3. Enter your Freeway API endpoint (e.g., `http://localhost:8000`)
4. Enter your admin API key
5. Click **Test Connection** to verify
6. Click **Save**

## Screens

### Dashboard
- Service health status
- Total projects and active count
- Today's requests and monthly cost
- Currently selected free and paid models

### Models
- Tabbed view for Free and Paid models
- Search by model name or ID
- View model details including pricing and context length

### Projects
- List all projects with status badges
- Create new projects
- Edit project name, rate limit, and active status
- Rotate API keys (with secure copy)
- Delete projects

### Settings
- API endpoint configuration
- Admin API key (stored securely)
- Theme selection (Light/Dark/System)

## Architecture

Built with Clean Architecture principles:

```
lib/
├── config/
│   ├── routes/         # GoRouter navigation
│   └── theme/          # Light/dark themes
├── core/
│   └── network/        # Dio client with auth
├── data/
│   └── datasources/    # API client
├── presentation/
│   ├── features/       # Screen implementations
│   │   ├── dashboard/
│   │   ├── models/
│   │   ├── projects/
│   │   └── settings/
│   ├── providers/      # Riverpod state
│   └── shared/         # Common widgets
└── main.dart
```

### Technologies

- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Secure Storage**: flutter_secure_storage
- **Theming**: Material 3 with Google Fonts

## Building

```bash
# Build for Windows
flutter build windows

# Build for macOS
flutter build macos

# Build for Linux
flutter build linux

# Build for Web
flutter build web
```

## Related

- [Freeway API](../freeway) - The backend AI Gateway
