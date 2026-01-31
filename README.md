# 🏢 Meeting Room Booking System (Flutter Web)

A professional Flutter Web application for managing meeting room bookings with a clean business UI and real-time dashboard.

## 🚀 Features

- ✅ **Login System** - Simple authentication with username/password validation
- ✅ **Dashboard View** - Real-time booking management interface
- ✅ **Add Booking** - Create bookings with room name, user name, and automatic timestamp
- ✅ **Delete Booking** - Swipe-to-delete functionality for easy removal
- ✅ **Logout System** - Secure session management and logout flow
- ✅ **Real-time UI Updates** - Stream-based data binding with Firestore
- ✅ **Responsive Design** - Professional Material Design 3 UI

## 🛠 Tech Stack

- **Framework**: Flutter (Web)
- **Language**: Dart
- **Backend**: Firebase Firestore (Real-time Database)
- **UI**: Material Design 3
- **Architecture**: Clean Code Structure with Service Layer

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & Firebase init
├── screens/
│   ├── login_screen.dart             # Login UI with navigation
│   └── dashboard_screen.dart         # Dashboard with CRUD operations
├── models/
│   └── booking.dart                  # Booking data model
└── services/
    └── firestore_service.dart        # Firebase Firestore service layer
```

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase Project Account

### Step 1: Clone & Install

```bash
git clone <your-repo-url>
cd meeting_room_booking_app
flutter pub get
```

### Step 2: Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project → Add Web App
3. Copy your config values
4. Replace in `lib/main.dart`:

```dart
FirebaseOptions(
  apiKey: "YOUR_API_KEY",
  appId: "YOUR_APP_ID",
  messagingSenderId: "YOUR_SENDER_ID",
  projectId: "YOUR_PROJECT_ID",
)
```

5. Enable **Firestore Database** → Start in test mode

### Step 3: Run the App

```bash
flutter run -d chrome
```

## 📱 How to Use

1. **Login**: Enter any username and password, then tap "Login"
2. **View Dashboard**: See all active bookings in real-time
3. **Add Booking**: Tap the "+" button to create a new booking
4. **Delete Booking**: Swipe left on a booking to remove it
5. **Logout**: Tap the logout icon in the AppBar

## 🎯 Key Implementation Details

### Authentication Flow
- Simple validation on login screen
- Navigation to dashboard after validation
- Logout button with session reset

### CRUD Operations
- **Create**: Add bookings with room name and timestamp
- **Read**: Stream real-time bookings from Firestore
- **Delete**: Dismissible widget with automatic Firestore delete

### Real-time Database
- Firestore integration for data persistence
- StreamBuilder for reactive UI updates
- Automatic timestamp on booking creation

## 🏗 Code Quality

- ✅ Clean Architecture with separation of concerns
- ✅ Service layer for business logic
- ✅ Model mapping for data consistency
- ✅ No hardcoded values or magic strings
- ✅ Proper error handling and UI feedback

## 🚀 Deployment

### Build for Web
```bash
flutter build web
```

### Deploy to GitHub Pages
1. Push code to GitHub
2. Enable GitHub Pages in repository settings
3. Select `gh-pages` branch for deployment
4. Your app will be live at `https://yourusername.github.io/meeting-room-booking-flutter`

## 📸 Screenshots

- **Login Page**: Clean, simple authentication interface
- **Dashboard**: Real-time booking list with management options
- **Add Booking**: Quick dialog for creating new bookings

## 🤝 Contributing

Feel free to fork, modify, and improve this project!

## 📝 License

This project is open source and available for portfolio and learning purposes.

---

**Built with ❤️ using Flutter & Firebase**

*Perfect for demonstrating: Flutter Web, Firebase Integration, CRUD Operations, Clean Code Architecture*

