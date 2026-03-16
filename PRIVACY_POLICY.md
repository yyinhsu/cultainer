# Privacy Policy

**Last updated:** March 16, 2026

## Overview

Cultainer ("we", "our", "us") is a personal media consumption tracker and knowledge extraction tool. This Privacy Policy explains how we collect, use, and protect your information.

## Information We Collect

### Account Information
- **Google Account data**: When you sign in with Google, we receive your display name, email address, and profile photo URL. We use this solely for authentication and displaying your profile within the app.

### User-Generated Content
- **Media entries**: Books, movies, TV shows, and music you track, including titles, ratings, reviews, and status.
- **Excerpts**: Text excerpts, notes, and AI analysis results you save.
- **Tags**: Custom tags you create for organizing entries.

### Third-Party API Data
- **Google Books / TMDB / Spotify**: When you search for media, queries are sent to these services to retrieve metadata (titles, covers, descriptions). We do not share your personal data with these services.
- **Google Gemini API**: When you use AI features (analysis, summarization, review enhancement), your excerpt text is sent to Google's Gemini API for processing. Your API key is stored locally on your device.
- **Google ML Kit**: OCR text recognition is processed on-device. No image data is sent to external servers.

## How We Store Your Data

- All user data (entries, excerpts, tags, profile) is stored in **Google Firebase** (Firestore) under your authenticated account.
- Data is synced across your devices via Firebase.
- Your **Gemini API key** is stored locally on your device using SharedPreferences and is never uploaded to our servers.

## Data Sharing

We do **not**:
- Sell your personal data to third parties
- Share your data with advertisers
- Use your data for purposes other than providing the app's functionality

We **do** share data with:
- **Google Firebase**: For authentication and data storage (governed by [Google's Privacy Policy](https://policies.google.com/privacy))
- **Google Gemini API**: Only when you explicitly trigger AI features, and only the text you choose to analyze

## Data Retention

- Your data is retained as long as you maintain an active account.
- You can delete individual entries, excerpts, and tags at any time within the app.
- To delete your entire account and all associated data, contact us at the email below.

## Security

- All data transmission uses HTTPS encryption.
- Firebase Security Rules restrict data access to authenticated users viewing only their own data.
- We follow industry-standard security practices.

## Children's Privacy

Cultainer is not directed at children under 13. We do not knowingly collect personal information from children under 13.

## Changes to This Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy within the app.

## Contact Us

If you have questions about this Privacy Policy, please open an issue at our GitHub repository or contact us via email.

---

*This privacy policy applies to the Cultainer mobile and desktop application.*
