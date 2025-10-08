# Username Feature Setup Guide

This guide explains how to set up and test the username selection feature for the Flutter app.

## Overview

The username feature allows users to select a unique username after signing up or signing in. This username serves as an identifier that other users can use to search for them. The implementation includes local caching for offline functionality and improved performance.

## Implementation Details

### 1. Database Setup

Before testing the feature, you need to create the `user_profiles` table in your Supabase database:

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Run the SQL migration file located at `supabase/migrations/20231008_create_user_profiles.sql`

This will create:
- A `user_profiles` table with a unique username field
- Row Level Security (RLS) policies to ensure users can only access their own profile
- Indexes for efficient username lookups
- Triggers to automatically update the `updated_at` timestamp

### 2. Feature Components

The implementation includes:

#### Username Screen (`lib/screens/username_screen.dart`)
- A form where users can input their desired username
- Validation for username requirements (3-20 characters, alphanumeric + underscore)
- Real-time validation feedback
- Error handling for duplicate usernames

#### AuthService Updates (`lib/services/auth_service.dart`)
- `saveUsername()`: Saves a username for the current user (both locally and remotely)
- `getUsername()`: Retrieves the current user's username (checks cache first)
- `hasUsername()`: Checks if the current user has a username (checks cache first)
- `isUsernameAvailable()`: Checks if a username is already taken
- `updateUsername()`: Updates the current user's username (both locally and remotely)
- `initPreferencesService()`: Initializes the local preferences service

#### UserPreferencesService (`lib/services/user_preferences_service.dart`)
- Handles local caching of username and user ID
- Provides offline access to username information
- Manages cache validation and cleanup
- Ensures data belongs to the correct user

#### Authentication Flow Updates
- Sign-up flow now prompts for username after successful registration
- Sign-in flow checks if user has a username and prompts if not
- AuthWrapper monitors authentication state and redirects to username screen if needed
- Username information is cached locally for offline access

## Testing the Feature

### New User Sign-up Flow
1. Install and run the app
2. Navigate to the sign-up screen
3. Enter your email and password
4. After successful registration, you'll be prompted to select a username
5. Enter a valid username (3-20 characters, alphanumeric + underscore)
6. After saving the username, you'll be redirected to the sign-in screen
7. Sign in with your credentials

### Existing User Sign-in Flow (without username)
1. If you have an existing account without a username
2. Sign in with your credentials
3. You'll be automatically redirected to the username selection screen
4. Select a username to continue

### Validation Testing
Test these scenarios:
1. Username too short (less than 3 characters)
2. Username too long (more than 20 characters)
3. Username with invalid characters
4. Duplicate username (should show an error)
5. Successful username selection

## Implementation Notes

### Security Considerations
- Row Level Security (RLS) is enabled on the user_profiles table
- Users can only access and modify their own profile
- Username uniqueness is enforced at the database level

### Error Handling
- Duplicate username attempts show user-friendly error messages
- Network errors are properly handled with appropriate feedback
- Loading states prevent multiple submissions

### Offline Functionality
The app now supports offline functionality through local caching:
- Username is cached locally after successful selection
- App can be opened offline if username is already cached
- Cache is validated against current user ID to prevent data leakage
- Cache is automatically cleared on sign out

### Performance Improvements
- Username checks are performed locally first, reducing API calls
- Only fetches from database when cache is empty or invalid
- Faster app startup time for returning users
- Reduced network usage and improved responsiveness

### Future Enhancements
- Username suggestions for taken usernames
- Profile customization options
- Username search functionality
- Social sharing with username
- Background sync for username updates

## Troubleshooting

### Database Issues
If you encounter database-related errors:
1. Ensure the SQL migration has been run in Supabase
2. Check that RLS policies are correctly configured
3. Verify the Supabase client configuration in main.dart

### Authentication Issues
If users aren't being redirected to the username screen:
1. Check that the AuthService is properly initialized
2. Verify the auth state changes are being monitored
3. Ensure the hasUsername() method is working correctly
4. Check that the UserPreferencesService is initialized in AuthWrapper

### Cache Issues
If cached username data seems incorrect:
1. Clear app data and sign in again to refresh cache
2. Check that user ID validation is working correctly
3. Verify cache is properly cleared on sign out

### Offline Issues
If the app doesn't work offline:
1. Ensure shared_preferences is properly added to pubspec.yaml
2. Check that UserPreferencesService is initialized before use
3. Verify cache is being saved correctly after username selection

### UI Issues
If the username screen has display issues:
1. Check that all required dependencies are in pubspec.yaml
2. Verify that the UsernameScreen import is correct in navigation files
3. Ensure the color constants are properly defined