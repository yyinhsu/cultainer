# Data Collection Declaration

This document outlines the data types collected by Cultainer for App Store and Google Play data safety disclosures.

## Data Types Collected

### 1. Contact Info
| Data Type | Collected | Purpose | Linked to Identity | Tracking |
|-----------|-----------|---------|-------------------|----------|
| Email Address | Yes | Authentication (Google Sign-In) | Yes | No |
| Name | Yes | Display in user profile | Yes | No |

### 2. User Content
| Data Type | Collected | Purpose | Linked to Identity | Tracking |
|-----------|-----------|---------|-------------------|----------|
| Media entries (books, movies, TV, music) | Yes | App functionality | Yes | No |
| Text excerpts and notes | Yes | App functionality | Yes | No |
| Tags | Yes | App functionality | Yes | No |
| Reviews and ratings | Yes | App functionality | Yes | No |

### 3. Identifiers
| Data Type | Collected | Purpose | Linked to Identity | Tracking |
|-----------|-----------|---------|-------------------|----------|
| User ID (Firebase UID) | Yes | Authentication | Yes | No |

### 4. Usage Data
| Data Type | Collected | Purpose | Linked to Identity | Tracking |
|-----------|-----------|---------|-------------------|----------|
| Crash logs | No | — | — | — |
| Analytics | No | — | — | — |

## Data Not Collected
- Financial information
- Location data
- Health & fitness data
- Browsing history
- Search history (searches are transient, not stored)
- Contacts
- Photos or videos (OCR is processed on-device)
- Audio data
- Diagnostics

## Third-Party SDKs
| SDK | Data Shared | Purpose |
|-----|-------------|---------|
| Firebase Auth | Email, name, profile photo | Authentication |
| Cloud Firestore | User-generated content | Data storage & sync |
| Google Books API | Search queries | Media metadata lookup |
| TMDB API | Search queries | Media metadata lookup |
| Spotify API | Search queries | Media metadata lookup |
| Google Gemini API | User-provided text excerpts | AI text analysis (user-initiated only) |
| Google ML Kit | None (on-device) | OCR text recognition |

## Data Retention & Deletion
- Data is retained while the user maintains an active account.
- Users can delete individual entries at any time.
- Full account deletion available upon request.

## Encryption
- All data in transit: HTTPS/TLS
- Data at rest: Firebase default encryption
- API keys: Stored locally on device
