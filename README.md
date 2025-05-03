# iApplied

## 📱 Job Application Tracker App (iOS 18+)

iApplied is a offline iOS app designed to help users track job applications and manage CV data efficiently. Built with SwiftUI and The Composable Architecture (TCA), it ensures that the job application process remains organized, timely, and easily accessible, all while keeping user data secure and stored locally with GRDB.

---

## 🎯 Current Features

### 🔹 Jobs Tab

- **Add Application**
  - Triggered via a bottom sheet form
  - Fields:
    - Job Title (required)
    - Company Name (required)
    - Date Applied (default: today)
    - Application Status (e.g., Applied, Interview, Offer, Declined)
    - Notes (optional)

- **Job List**
  - Displayed as cards:
    - **Full mode**: Shows title, company, days since applied, and a status badge.
    - **Compact mode**: Displays title, status color, and an icon indicating days since applied.
  - Toggle between full and compact views.

- **Follow-Up Notifications**
  - Local notifications are scheduled after a configurable number of days (default: 7 days).
  - Notifications trigger only for jobs in specific statuses (e.g., "Applied").

- **Job Archiving**
  - Automatic archiving when the status is set to "Declined."
  - Manual archiving option available.

- **Delete Job**
  - Jobs can be deleted from any state.

### 🔹 CV Tab

- **Professional Links Section**
  - Add links to professional profiles (GitHub, LinkedIn, portfolio, etc.)
  - Each link includes:
    - A custom title
    - A URL
    - A selectable icon
    - Copy functionality for quick sharing

---

## 🚀 Planned Features

### 🔹 CV Tab Enhancements

- **Manual Entry**
  - **Experience Section**: Add and manage work history
  - **Education Section**: Track educational background
  - **Skills Section**: List technical and soft skills
  - **About Me**: Personal statement/summary

- **CV File Management**
  - Upload and save PDF versions of your CV
  - View, share, and copy functionality

---

## 🖌️ Design & UI

- **Color Scheme**: Clean and modern with accent colors for different application statuses.
- **Layout**: Card-based job display and tab-based navigation.
- **Typography**: Uses the system font (SF Pro) for a native iOS feel.

---

## 🧰 Technical Notes

- **Target Platform**: iOS 18+
- **UI Framework**: SwiftUI (fully native, no UIKit)
- **Architecture**: The Composable Architecture (TCA)
- **Data Storage**: GRDB (SQLite) with local database
- **Notifications**: UNUserNotificationCenter for local alerts

---

## 🚀 Getting Started

1. Clone the repository.
2. Open the project in Xcode 16 or later.
3. Build and run on an iOS 18+ device or simulator.

---

## 📝 Privacy

iApplied stores all data locally on your device using SQLite. No data is sent to external servers, ensuring your job search remains completely private.

---

## 🛠️ Project Structure

```
iApplied/
├── Sources/
│   ├── AppDatabase/        # Database management
│   ├── CV/                 # CV tab implementation
│   ├── Jobs/               # Jobs tab implementation
│   │   ├── Notifications/  # Follow-up notification system
│   │   └── View/           # Job list/card views
│   ├── Models/             # Data models
│   ├── Root/               # App root and tab navigation
│   └── Theme/              # UI theme definitions
└── Tests/
    └── JobsTest/           # Unit tests
```

---

Built with ❤️ for job seekers
