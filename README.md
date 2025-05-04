# iApplied

A lightweight iOS app for tracking job applications, managing CV details, and scheduling timely follow-ups — all while keeping your data 100% offline and private.

---

## 📦 About

iApplied helps job seekers stay organized throughout the job application process. Track roles you've applied for, manage your CV links and details, and get gentle nudges to follow up — all without sending data to external servers.

---

## 🛠️ Technologies

- **Platform**: iOS 18+
- **UI**: SwiftUI (native)
- **Architecture**: [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture)
- **Local Storage**: GRDB (SQLite)
- **Notifications**: UNUserNotificationCenter

---

## 🎯 Features

### 📋 Jobs

- Add new applications with:
  - Title
  - Company
  - Application status
  - Date (default: today)
  - Notes (optional)
- Toggle between full and compact card views
- Manual archive or delete options
- Local notifications to follow up (default: 7 days)

### 📄 CV

- Save professional links (GitHub, LinkedIn, portfolio, etc.)
- Each link supports:
  - Custom title
  - URL
  - Icon selection
  - Tap-to-copy for quick sharing

---

## 🧪 Planned Features

- **Manual CV Entry**
  - Experience, education, skills, and “About Me” section
- **CV File Support**
  - Upload and store PDFs
  - View, copy, and share resumes

---

## 📱 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/Muhammed9991/iApplied
   ```
2. Open in Xcode 16 or later.
3. Build and run on an iOS 18+ device or simulator.

---

## 🔒 Privacy First

All data is stored **locally on your device** using SQLite.  
No analytics, no trackers, no external storage — your job hunt stays private.

---

## 🪪 License

iApplied is available under the [GNU General Public License v3.0](LICENSE).

---

Built with ❤️ for job seekers.
