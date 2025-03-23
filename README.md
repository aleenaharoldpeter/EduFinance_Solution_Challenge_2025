# EduFinanceConnect

## Problem Statement

**Breaking Financial Barriers to Ensure Equal Access to Education**

Many students from lower-income families struggle with financial constraints, leading to dropped classes, poor academic performance, and a cycle of poverty. **EduFinanceConnect** is designed to break these barriers by connecting students with relevant scholarship opportunities—making it easier to find, track, and apply for financial assistance.

---

## Why Our Solution Makes Sense

### Targeted Focus
Unlike broad national portals, **EduFinanceConnect** is built specifically for lower-income students. Our platform focuses solely on scholarships, offering a streamlined, user-friendly experience tailored to our audience.

### Localized Multi-Language Support
The app supports **Hindi**, **Kannada**, and **English**, ensuring accessibility for students who may not be comfortable with English-only platforms. This localized support improves usability and inclusivity.

---

## Essential Features (MVP)

### Scholarship Filtering
- **Search & Filter:** Easily search for scholarships based on state, qualification, category, and deadlines.
- **CSV Data Loading & Caching:** Scholarships are loaded from a CSV file and cached for offline use, ensuring fast access and reliability.

### Multi-Language Support
- **On-Device Translation:** Built-in support for Hindi, Kannada, and English using ML Kit on-device translation.
- **Dynamic UI Updates:** Global notifiers update UI text based on the selected language in real-time.

### Deadline Reminder Notifications
- **Set Reminders:** Users can set reminders for upcoming scholarship deadlines.
- **Live Countdown:** Each reminder displays a live countdown timer along with full details (Scholarship ID, state, qualification, category, amount, deadline).
- **Local Notifications:** Scheduled using a local notification service to ensure users never miss a deadline.

### Scholarship Bookmarking & Application Tracker
- **Bookmarking:** Save scholarships for future reference using a unique Scholarship ID.
- **Application Tracker:** Mark scholarships as "Applied", "In Progress", or "Not Interested" to manage application status.

### Community Forum
- **Peer Support:** A dedicated space for students to share insights, ask questions, and get advice regarding scholarships and application processes.

### Basic Rule-Based Chatbot
- **Integrated Chatbot:** Accessible via a floating icon on the dashboard.
- **Pre-Filled FAQs:** Provides answers and guidance on common queries related to filtering, bookmarking, tracking, and reminders.

---

## Future Enhancements

### AI-Driven Personalization & Smart Recommendations
- **Advanced AI Tools:** Integrate Google Gemini APIs or Vertex AI to offer personalized scholarship recommendations.
- **Automated Data Extraction:** Enable real-time updates by automatically extracting and refreshing scholarship data from external sources.

### Conversational AI Chatbot
- **NLP-Driven Experience:** Upgrade the basic rule-based chatbot to a fully conversational AI chatbot for enhanced user support.

### Local Area Integration
- **Localized Opportunities:** Integrate scholarship opportunities specific to local areas.
- **Community Partnerships:** Establish partnerships with local educational institutions and government bodies for real-time updates and notifications.

### Expanded Multi-Language Support
- **Additional Languages:** Expand support to regional languages such as Marathi, Tamil, Telugu, and Bengali.

### Advanced User Engagement & Analytics
- **Feedback & Success Stories:** Incorporate mechanisms for user feedback and success stories.
- **Analytics:** Implement analytics to refine the recommendation engine and enhance user experience.

### Scalable Cloud Infrastructure
- **Cloud Migration:** Migrate to Google Cloud Platform (GCP) using Firestore/BigQuery for improved performance, scalability, and data management.

---

## Prerequisites

- **Flutter SDK:**  
  Ensure you have Flutter installed. Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install) for your operating system.

- **Firebase Project:**  
  Set up a Firebase project and add the necessary configuration files:
  - `google-services.json` for Android
  - `GoogleService-Info.plist` for iOS
  - `firebase_options.dart` (generated using FlutterFire CLI)

- **Firebase CLI (for hosting the web version):**  
  Install via Node.js:
  ```bash
  npm install -g firebase-tools
  ```
- **Dependencies:**

    All required dependencies (e.g., firebase_auth, shared_preferences, google_mlkit_translation, etc.) are listed in the pubspec.yaml file
## Installation & Setup
**1. Clone the Repository:**

~~~bash
git clone <repository-url>
cd EduFinanceConnect
~~~
**2. Install Flutter Packages:**    

```bash
flutter pub get
```
**3. Set Up Firebase:**

- Follow the [FlutterFire documentation](https://firebase.flutter.dev/docs/overview/) to add Firebase to your project.
- Place your `google-services.json`, `GoogleService-Info.plist`, and generated `firebase_options.dart` in the appropriate directories.

**4. Set Up Firebase:**
- **For mobile (Android/iOS):**
    ```bash
    flutter run
    ```
- **For web (after enabling web support):**
    ```bash
    flutter run -d chrome
    ```

**5. Deploying to Firebase Hosting (Web Version):**
- **Enable web support:**
    ```bash
    flutter config --enable-we
    ```
- **Build the web app:**
    ```bash
    flutter build web
    ```
- **Initialize Firebase Hosting in your project:**
    ```bash
    firebase init hosting
    ```
    - Choose your Firebase project.
    - Set the public directory to `build/web`.
    - Select “Yes” for configuring as a single-page app.
- **Deploy**

    ```bash
    firebase deploy
    ```
---

## How the App Works

### Dashboard
- **Quick Access:**  
  Upon login, the dashboard provides quick access to key features:
  - **Scholarship Filtering**
  - **Community Forum**
  - **Application Tracker**
  - **Reminders**
- **Floating Chat Icon:**  
  A floating chat icon is available for FAQs and support.

### Scholarship Filtering
- **Filter Options:**  
  Users can filter scholarships by:
  - **State**
  - **Qualification**
  - **Category**
- **Scholarship Details:**  
  Each scholarship is displayed with the following details:
  - **Scholarship ID**
  - **State**
  - **Qualification**
  - **Category**
  - **Amount**
  - **Deadline**
- **Actions:**  
  Options available for each scholarship include:
  - **Apply**
  - **Bookmark**
  - **Update Status**
  - **Set a Reminder**

### Application Tracker
- **Manage Bookmarks:**  
  Keep track of bookmarked scholarships.
- **Update Status:**  
  Update the application status to:
  - **Applied**
  - **In Progress**
  - **Not Interested**

### Reminders
- **Set Reminders:**  
  Users can set reminders for upcoming scholarship deadlines.
- **Live Countdown:**  
  Each reminder displays full details along with a live countdown timer.

### Chatbot
- **Basic Rule-Based Chatbot:**  
  Accessed via a floating icon on the dashboard.
- **Prefilled FAQs:**  
  Provides prefilled FAQs and guidance on:
  - Filtering
  - Bookmarking
  - Tracking
  - Reminders
- **Future Upgrade:**  
  The current chatbot will be transformed into a fully conversational AI chatbot for enhanced support.

---

## Future Roadmap

### AI-Driven Personalization & Smart Recommendations
- **Tailored Scholarship Recommendations:**  
  Utilize advanced AI tools to provide personalized scholarship suggestions.
- **Automated Data Extraction:**  
  Integrate IDX for automated data extraction from external sources to ensure real-time scholarship updates.
- **Gemini API Integration:**  
  Leverage Google Gemini APIs for advanced, AI-powered personalization and recommendation services.

### Conversational AI Chatbot
- **NLP-Driven Solution:**  
  Upgrade the current FAQ-based chatbot to a full NLP-driven solution for improved interaction.

### Local Area Integration
- **Localized Opportunities:**  
  Integrate localized scholarship opportunities and notifications.
- **Enhanced User Engagement:**  
  Increase community relevance and engagement through local area integrations.

### Expanded Multi-Language Support
- **Additional Regional Languages:**  
  Add support for languages such as:
  - Marathi
  - Tamil
  - Telugu
  - Bengali

### Advanced Analytics & User Engagement
- **User Feedback:**  
  Incorporate user feedback and success stories.
- **Data Analytics:**  
  Use detailed analytics to continuously improve the recommendation engine and overall user experience.

### Scalable Cloud Infrastructure
- **Cloud Migration:**  
  Migrate to a scalable cloud platform (e.g., GCP with Firestore/BigQuery) for enhanced performance and scalability.

---

## Evaluation & Impact

**EduFinanceConnect** addresses the financial barriers faced by lower-income students by making scholarship information accessible through a focused and user-friendly interface.  
With built-in multi-language support, localized features, and a clear path toward AI-driven enhancements—including IDX-powered data extraction and Gemini API integration—our app is poised to make a significant social impact while ensuring that financial assistance reaches those who need it most.

---




<!-- # financial

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference. -->
