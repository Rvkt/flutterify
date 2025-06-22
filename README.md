# flutterify

## Project Structure Overview

This Flutter project follows a modular, scalable architecture inspired by Clean Architecture and Layered Architecture principles. 
Below is an overview of the folder structure and the purpose of each directory:

```
lib/
├── core/                          # Core utilities shared across the app
│   ├── constants/                 # App-wide constant values (e.g. strings, keys)
│   ├── main_app.dart              # Root widget of the application
│   ├── navigation/               # Navigation logic (routes, nav helpers)
│   ├── network/                  # Network layer for handling API requests
│   │   ├── client/               # API setup (clients, endpoints, headers, etc.)
│   │   ├── handler/              # Response/error handling and exceptions
│   │   └── service/              # Abstraction layer over API client
│   ├── theme/                    # Global theme definitions
│   └── utils/                    # Utility functions and helpers
│
├── features/                     # Feature-based module separation
│   └── products/                 # 'Products' feature module
│       ├── bloc/                 # BLoC (Business Logic Component) for state management
│       ├── data/                 # Data layer (models and repositories)
│       │   ├── models/           # Data models (usually matching API schema)
│       │   └── repositories/     # Repositories for API/data logic
│       └── presentation/         # UI layer for this feature
│           ├── screens/          # Full-screen views/pages
│           └── widgets/          # Reusable UI components
│
├── injection/                   # Dependency injection setup (e.g., using `get_it`)
│   └── injection_container.dart  # Service locator setup
│
├── main.dart                     # App entry point
│
└── shared/                       # Reusable components across features
    ├── mixins/                   # Common Dart mixins
    └── widgets/                  # Shared widgets across the app

```
