# ApplyPal

## 📱 Job Application Tracker App (iOS 18+)

A simple, private iOS app designed to track job applications and manage CV data. The app focuses on keeping the application process organized, timely, and easily referenceable.

---

## 🎯 Features

### 🔹 Jobs Tab

- **Add Application**
  - Triggered via a bottom sheet form
  - Fields:
    - Job Title (required)
    - Company Name (required)
    - Date Applied (default: today)
    - Application Status (e.g. Applied, Interview, Offer, Declined)
    - Notes (optional)

- **Job List**
  - Displayed as cards:
    - **Full mode**: title, company, days since applied, status badge
    - **Compact mode**: title + status color + icon showing days since applied
  - Toggle between full and compact view

- **Follow-Up Notification**
  - Local notification scheduled after X days (X configurable later)
  - Triggers only if job is in certain statuses (e.g., "Applied")

- **Job Archiving**
  - Automatic when status is "Declined"
  - Manual archive option

- **Delete Job**
  - Available from any state

---

### 🔹 CV Tab

- **Manual Entry**
  - **Experience Section**: Add and manage work history
  - **Education Section**: Track educational background
  - **Skills Section**: List technical and soft skills
  - **About Me**: Personal statement/summary
  - Each section is editable and copyable with dedicated buttons

- **Upload CV File**
  - Save a local PDF
  - Actions:
    - View
    - Share via share sheet
    - Copy to clipboard

- **Links Section**
  - GitHub, LinkedIn, Portfolio, etc.
  - Each with:
    - Label
    - Icon
    - Copy button

---

## 🖌️ Design & UI

### 🎨 Color Scheme

| Element          | Color                    |
|------------------|--------------------------|
| Primary          | #2C3E50 (Midnight Blue) |
| Accent           | #1ABC9C (Aqua Green)    |
| Background       | #F5F5F5 (Soft Gray)     |
| Cards            | #FFFFFF (White)         |
| Applied Status   | Blue                    |
| Interview Status | Orange                  |
| Offer Status     | Green                   |
| Declined         | Red                     |
| Archived         | Gray                    |

### 🧱 Layout

- SwiftUI only (iOS 18+)
- Uses bottom sheet for form input (new in iOS 18)
- Card-based job display
- Tab-based navigation (Jobs / CV)
- Rounded corners (8–12px), light shadows
- Clean grid-based layout

### 🖋 Typography

- **System Font** (SF Pro)
- Title: Semibold
- Body: Regular
- Caption: Light

---

## 🧰 Technical Notes

- **Target Platform:** iOS 18+
- **UI Framework:** SwiftUI (fully native, no UIKit)
- **Data Storage:** Local data storage with `AppDataStore`
- **Notifications:** `UNUserNotificationCenter` for local alerts

## 🚀 Getting Started

1. Clone the repository
2. Open the project in Xcode 16 or later
3. Build and run on iOS 18+ device or simulator

## 📝 Privacy

ApplyPal stores all data locally on your device. No data is sent to external servers, ensuring your job search remains completely private.

## 🛠️ Project Structure

```
ApplyPal/
├── ApplyPalApp.swift         # App entry point
├── ContentView.swift         # Main container view
├── Models/                   # Data models
│   ├── AppDataStore.swift    # Main data storage
│   ├── CVData.swift          # CV data structures
│   ├── JobModels.swift       # Job application models
├── Theme/                    # UI theme definitions
├── Views/                    # UI components
│   ├── CV/                   # CV management views
│   ├── Jobs/                 # Job tracking views
│   └── Settings/             # App settings
```

---

Built with ❤️ for job seekers
