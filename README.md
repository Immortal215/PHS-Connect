# Clubs App

## Overview

> [!INFO] **Overview**
> The Clubs App is designed to provide a structured and interactive platform for students to discover, join, and manage clubs. 🎉 With features like personalized club recommendations, custom calendars, and streamlined communication tools, the app empowers students to engage more effectively in extracurricular activities.

---

## Features

### 1. **Club Management**

> [!NOTE] **Manage clubs effortlessly** 🛠️

- **Leaders and Members:**
  - Club leaders can manage members, make announcements, and set meeting times.
  - Flexible visibility settings (“All”, “Non-Guests Only”, “Members Only”, “Leaders Only”) ensure sensitive data is displayed appropriately.
- **Invite-Only Clubs:**
  - Users can request to join invite-only clubs, pending approval from leaders.

### 2. **User Profiles**

- Personalized profiles store:
  - Favorited clubs
  - Subject preferences
  - Clubs they are a part of
  - Pending club join requests

### 3. **Club Discovery**

- Users can:
  - Browse clubs with a short description and abstract.
  - View genres, meeting times, announcements, and photos to make informed decisions about joining.

### 4. **Custom Calendar View**

> 📅 **Stay organized with our unique calendar feature!**

- A unique calendar feature displays meeting times for favorited clubs, independent of Apple’s system calendars.

### 5. **Announcements**

- Leaders can post announcements with timestamps to keep members informed.

### 6. **Google Login**

- Secure and convenient authentication using Google accounts.

### 7. **Firebase Integration**

- Real-time data syncing powered by Firebase Realtime Database ensures smooth operation.

---

## Technical Details

> [!IMPORTANT] **Dive into the technical backbone** 🧑‍💻

### 1. **Models**

#### `Personal`

```swift
struct Personal: Codable {
    var favoritedClubs: [String]
    var subjectPreferences: [String]
    var clubsAPartOf: [String]
    var pendingClubRequests: [String]?
}
```

#### `Club`

```swift
struct Club: Codable, Equatable {
    var leaders: [String] // emails
    var members: [String] // emails
    var inviteOnly: Bool
    var announcements: [String: String]?
    var meetingTimes: [String: [String]]?
    var description: String
    var name: String
    var schoologyCode: String
    var genres: [String]?
    var clubPhoto: String?
    var abstract: String
    var showDataWho: String
    var pendingMemberRequests: [String]?
    var clubID: String

```


### 2. **UI Components**

- **Custom Calendar View:**
  - Built using SwiftUI to show meeting times for favorited clubs.
- **Add Announcement Sheet:**
  - Structured with `struct AddAnnouncementSheet: View` for leaders to create and save announcements.

### 3. **Backend**

- **Firebase Realtime Database:**
  - Securely stores club and user data.
  - Ensures real-time updates for announcements, member lists, and more.

---

## Getting Started

### Prerequisites

- Xcode 14 or later
- Swift 5.7 or later
- Firebase SDK
- Google Sign-In configuration

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Immortal215/PHS-Connect.git
   ```
2. Open the `.xcodeproj` file in Xcode.
3. Install dependencies via Swift Package Manager.
4. Configure Firebase by adding your `GoogleService-Info.plist` file to the project.

### Running the App

1. Connect an iPad (optimized for Gen 10).
2. Build and run the app on your connected device or simulator.

## Contact

For questions or suggestions, please reach out to the development team.

