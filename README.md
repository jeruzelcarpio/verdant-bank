# Verdant Bank - Mobile Banking Application

A comprehensive mobile banking application developed as a university group project. Built with Flutter and Firebase, this app provides a full suite of banking features with a modern, user-friendly interface.

## About This Project

This application was developed as a collaborative university project to demonstrate proficiency in mobile application development, cloud integration, and financial software design. The project showcases modern development practices, including real-time data synchronization, secure authentication, and responsive UI design.

## Features

### Core Banking Operations
- **Account Management**: View account details, balance, and transaction history in real-time
- **Fund Transfers**: 
  - Transfer between Verdant Bank accounts
  - Transfer to other banks with transaction fees
  - Transfer to savings accounts
- **Bill Payments**: Pay utility bills, credit cards, internet, and other services
- **Mobile Load Purchase**: Buy prepaid mobile load for various networks

### Financial Services
- **Investment Platform**:
  - Cryptocurrency trading (buy/sell)
  - Stock market investments
  - Real-time market data visualization
- **Savings Goals**: 
  - Create and manage multiple savings plans
  - Track progress with visual indicators
  - Savings history charts

### Security & Authentication
- **Email Verification**: Secure account creation with email OTP verification
- **Firebase Authentication**: Industry-standard user authentication
- **Transaction Confirmation**: Slide-to-confirm mechanism for transactions
- **OTP Authorization**: Additional security layer for sensitive operations

### User Experience
- **Animated UI**: Smooth transitions and engaging animations
- **Card Flip Animation**: Interactive card display with flip animations
- **Transaction Receipts**: Detailed receipts with save and share functionality
- **Real-time Updates**: Live balance and transaction updates using Firestore streams
- **Responsive Design**: Optimized for various screen sizes

## Technology Stack

### Frontend
- **Flutter 3.7.2**: Cross-platform mobile application framework
- **Dart**: Primary programming language

### Backend & Cloud Services
- **Firebase Core**: Backend infrastructure
- **Cloud Firestore**: NoSQL database for real-time data synchronization
- **Firebase Authentication**: User authentication and management
- **Cloud Functions**: Serverless backend functions (email verification)

### Key Dependencies
- `fl_chart`: Financial data visualization and charts
- `google_fonts`: Custom typography
- `intl`: Internationalization and number formatting
- `image_picker`: Document and ID verification
- `permission_handler`: Camera and storage permissions
- `smooth_page_indicator`: Onboarding screen indicators
- `percent_indicator`: Savings goal progress visualization

## Architecture

### Data Models
- **Account**: User account information and balance management
- **Transaction**: Transaction records with source/destination tracking
- **Plan**: Savings goals with progress tracking

### Core Services
- **FirebaseService**: Centralized Firebase operations
- **UserSession**: Session management and user state
- **Firestore API**: Database operations and queries

### Component Structure
- **Reusable Components**: Modular UI components (cards, buttons, receipts)
- **Authentication Screens**: Complete onboarding and verification flow
- **Feature Modules**: Self-contained modules for each banking feature

## Database Schema

### Collections
- `accounts`: User account information
- `transactions`: Transaction history and records
- `savingsPlans`: User savings goals and progress

## Project Structure

```
lib/
├── alixScreens/              # Authentication and onboarding screens
├── animation_class/          # Custom animations
├── api/                      # API integration and Firestore operations
├── components/               # Reusable UI components
├── models/                   # Data models
├── services/                 # Business logic and services
├── theme/                    # App theming and colors
├── utils/                    # Utility functions
├── main.dart                 # Application entry point
└── [feature_screens].dart    # Feature-specific screens
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Firebase project with Firestore and Authentication enabled
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository
```bash
git clone https://github.com/jeruzelcarpio/verdant-bank.git
cd verdant-bank
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Configure Firebase in the Firebase Console

4. Run the application
```bash
flutter run
```

## Key Features Implementation

### Real-time Balance Updates
Utilizes Firestore StreamBuilder to provide live balance updates across all screens, ensuring data consistency.

### Transaction Processing
Implements Firestore transactions to ensure atomic operations when transferring funds between accounts, preventing race conditions.

### Savings Goal Tracking
Visualizes savings progress with interactive charts using `fl_chart` package, with data persisted in Firestore.

### Multi-step Verification
Implements a secure onboarding process with ID verification, email confirmation, and document upload capabilities.

## Development Team

This project was developed as a university group project, demonstrating collaborative software development and modern mobile banking application architecture.

## License

This project is developed for educational purposes as part of university coursework.

---

**Note**: This is an educational project and not intended for production use. All financial transactions are simulated and no real money is involved.
