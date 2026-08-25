# VibeChat Flutter API Integration Guide

## Overview
This guide explains how to integrate the VibeChat Flutter app with your Laravel backend API.

## Setup

### 1. Update API Configuration
Edit `/lib/api/api_config.dart` and update the base URL:

```dart
static const String BASE_URL = 'https://api.vibechat.one'; // Change this to your Laravel backend URL
```

Also update the WebSocket URL if you're implementing real-time features:

```dart
static String get websocketUrl => 'wss://api.vibechat.one/ws';
```

### 2. Install Dependencies
The following packages are already included in `pubspec.yaml`:
- `dio`: HTTP client
- `flutter_secure_storage`: Secure token storage

No additional packages need to be installed.

## API Structure

```
lib/api/
├── api_config.dart          # API endpoints configuration
├── api_client.dart          # Dio HTTP client with interceptors
├── api_response.dart        # Response wrapper
└── services/
    ├── auth_service.dart    # Authentication endpoints
    ├── user_service.dart    # User profile endpoints
    ├── chat_service.dart    # Chat and messaging endpoints
    ├── story_service.dart   # Stories endpoints
    ├── friend_service.dart  # Friends and requests endpoints
    ├── settings_service.dart # Settings endpoints
    └── api_services.dart    # Export file
```

## Usage Examples

### Authentication

#### Login
```dart
import 'package:com.darvin.vibechat/api/services/api_services.dart';

final authService = AuthService();

// Login
final response = await authService.login(
  identifier: 'username_or_email',
  password: 'password123',
);

if (response.isSuccess) {
  final data = response.data!;
  final accessToken = data['access_token'];
  final refreshToken = data['refresh_token'];
  final user = data['user'];
  
  // Save tokens
  await authService.saveTokens(accessToken, refreshToken);
  
  // Navigate to home
} else {
  // Show error
  print(response.errorMessage);
  
  // Show field-specific errors
  final emailError = response.getFirstFieldError('email');
  if (emailError != null) {
    print('Email error: $emailError');
  }
}
```

#### Register
```dart
final response = await authService.register(
  username: 'john_doe',
  email: 'john@example.com',
  password: 'password123',
  passwordConfirmation: 'password123',
  displayName: 'John Doe',
  dateOfBirth: DateTime(2000, 1, 1),
  acceptTerms: true,
);

if (response.isSuccess) {
  // Registration successful
  final data = response.data!;
  await authService.saveTokens(
    data['access_token'], 
    data['refresh_token'],
  );
}
```

#### Logout
```dart
final response = await authService.logout();
// Tokens are automatically cleared
```

#### Check Authentication
```dart
final isAuth = await authService.isAuthenticated();
if (isAuth) {
  // User is logged in
} else {
  // Redirect to login
}
```

### User Profile

```dart
import 'package:com.darvin.vibechat/api/services/api_services.dart';

final userService = UserService();

// Get current user
final response = await userService.getUserById('user_id');
if (response.isSuccess) {
  final user = response.data!; // UserModel
  print(user.displayName);
}

// Update profile
final updateResponse = await userService.updateProfile(
  displayName: 'New Name',
  bio: 'My new bio',
  pronouns: 'he/him',
);

// Upload avatar
final uploadResponse = await userService.uploadAvatar('/path/to/image.jpg');
if (uploadResponse.isSuccess) {
  final avatarUrl = uploadResponse.data!['avatar_url'];
  print('New avatar: $avatarUrl');
}

// Search users
final searchResponse = await userService.searchUsers(
  query: 'john',
  page: 1,
  perPage: 20,
);
if (searchResponse.isSuccess) {
  final users = searchResponse.data!; // List<UserModel>
  for (var user in users) {
    print(user.username);
  }
}

// Block user
await userService.blockUser('user_id');

// Get blocked users
final blockedResponse = await userService.getBlockedUsers();
```

### Chat & Messaging

```dart
import 'package:com.darvin.vibechat/api/services/api_services.dart';

final chatService = ChatService();

// Get all chats
final chatsResponse = await chatService.getChats();
if (chatsResponse.isSuccess) {
  final chats = chatsResponse.data!;
  // Display chats
}

// Get messages for a chat
final messagesResponse = await chatService.getChatMessages(
  chatId: 'chat_id',
  page: 1,
  perPage: 50,
);

// Send message
final sendResponse = await chatService.sendMessage(
  chatId: 'chat_id',
  content: 'Hello!',
  type: 'text',
);

// Send message with media
// First, upload the media
final uploadResponse = await chatService.uploadMedia(
  '/path/to/image.jpg',
  type: 'image',
  onProgress: (sent, total) {
    final progress = (sent / total * 100).toStringAsFixed(0);
    print('Upload progress: $progress%');
  },
);

if (uploadResponse.isSuccess) {
  final mediaUrl = uploadResponse.data!['media_url'];
  
  // Then send the message with media URL
  final sendResponse = await chatService.sendMessage(
    chatId: 'chat_id',
    content: 'Check this out!',
    type: 'image',
    mediaUrl: mediaUrl,
  );
}

// Edit message
await chatService.editMessage(
  messageId: 'message_id',
  content: 'Updated message',
);

// Delete message
await chatService.deleteMessage('message_id');

// React to message
await chatService.reactToMessage(
  messageId: 'message_id',
  emoji: '❤️',
);

// Mark chat as read
await chatService.markAsRead('chat_id');

// Search messages
final searchResponse = await chatService.searchMessages(
  query: 'important',
  chatId: 'chat_id', // optional
);
```

### Stories

```dart
import 'package:com.darvin.vibechat/api/services/api_services.dart';

final storyService = StoryService();

// Get all stories
final storiesResponse = await storyService.getStories();
if (storiesResponse.isSuccess) {
  final stories = storiesResponse.data!;
  // Display stories
}

// Create story
// First, upload media
final uploadResponse = await storyService.uploadStoryMedia(
  '/path/to/image.jpg',
  type: 'image',
  onProgress: (sent, total) {
    print('Upload: ${(sent / total * 100).toInt()}%');
  },
);

if (uploadResponse.isSuccess) {
  final mediaUrl = uploadResponse.data!['media_url'];
  
  // Then create the story
  final createResponse = await storyService.createStory(
    mediaUrl: mediaUrl,
    type: 'image',
    caption: 'My story caption',
    audience: 'friends',
    duration: 24, // hours
  );
}

// Mark story as viewed
await storyService.markStoryViewed('story_id');

// Get story viewers
final viewersResponse = await storyService.getStoryViewers(
  storyId: 'story_id',
);

// Delete story
await storyService.deleteStory('story_id');
```

### Friends & Friend Requests

```dart
import 'package:com.darvin.vibechat/api/services/api_services.dart';

final friendService = FriendService();

// Get friends list
final friendsResponse = await friendService.getFriends();
if (friendsResponse.isSuccess) {
  final friends = friendsResponse.data!; // List<UserModel>
  for (var friend in friends) {
    print(friend.displayName);
  }
}

// Get friend requests
final requestsResponse = await friendService.getFriendRequests(
  type: 'received', // 'received', 'sent', 'all'
);

// Send friend request
final sendResponse = await friendService.sendFriendRequest('user_id');
if (sendResponse.isSuccess) {
  print('Friend request sent!');
}

// Accept friend request
await friendService.acceptFriendRequest('request_id');

// Reject friend request
await friendService.rejectFriendRequest('request_id');

// Cancel sent friend request
await friendService.cancelFriendRequest('request_id');

// Unfriend user
await friendService.unfriend('user_id');
```

### Settings

```dart
import 'package:com.darvin.vibechat/api/services/api_services.dart';

final settingsService = SettingsService();

// Get privacy settings
final privacyResponse = await settingsService.getPrivacySettings();

// Update privacy settings
final updateResponse = await settingsService.updatePrivacySettings({
  'profile_visibility': 'public',
  'story_visibility': 'friends',
  'read_receipts': true,
});

// Change password
final passwordResponse = await settingsService.changePassword(
  currentPassword: 'old_password',
  newPassword: 'new_password',
  newPasswordConfirmation: 'new_password',
);

// Enable 2FA
final enable2FAResponse = await settingsService.enable2FA();
if (enable2FAResponse.isSuccess) {
  final qrCode = enable2FAResponse.data!['qr_code'];
  final secret = enable2FAResponse.data!['secret'];
  final recoveryCodes = enable2FAResponse.data!['recovery_codes'];
  // Show QR code to user
}

// Verify 2FA
final verify2FAResponse = await settingsService.verify2FA(
  code: '123456',
);

// Get login history
final historyResponse = await settingsService.getLoginHistory();

// Get active sessions
final sessionsResponse = await settingsService.getActiveSessions();

// Revoke session
await settingsService.revokeSession('session_id');

// Export data (GDPR)
final exportResponse = await settingsService.exportData();
if (exportResponse.isSuccess) {
  final exportId = exportResponse.data!['export_id'];
  // Poll for completion or show status
}

// Delete account
final deleteResponse = await settingsService.deleteAccount(
  password: 'user_password',
  reason: 'Optional reason',
);
```

## Error Handling

All API methods return `ApiResponse<T>` which includes:

```dart
final response = await authService.login(...);

// Check success
if (response.isSuccess) {
  // Access data
  final data = response.data;
} else {
  // Get error message
  final errorMessage = response.errorMessage;
  
  // Get status code
  final statusCode = response.statusCode;
  
  // Get field-specific errors (for validation errors)
  final emailError = response.getFirstFieldError('email');
  final passwordErrors = response.getFieldErrors('password');
  
  // Get all errors
  final errors = response.errors;
}
```

## Token Management

Tokens are automatically:
- Stored securely using `flutter_secure_storage`
- Added to all API requests via `Authorization` header
- Refreshed when expired (401 response)
- Cleared on logout

You don't need to manually handle tokens!

## Interceptors

The API client includes:
1. **Auth Interceptor**: Automatically adds Bearer token to requests
2. **Refresh Token Interceptor**: Automatically refreshes expired tokens
3. **Logging Interceptor**: Logs requests and responses (disable in production)

## Integration with Provider

Example of integrating with your existing `AppProvider`:

```dart
import 'package:flutter/foundation.dart';
import 'package:com.darvin.vibechat/api/services/api_services.dart';
import 'package:com.darvin.vibechat/models/user_model.dart';

class AppProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final response = await _authService.login(
      identifier: identifier,
      password: password,
    );
    
    _isLoading = false;
    
    if (response.isSuccess) {
      final data = response.data!;
      await _authService.saveTokens(
        data['access_token'],
        data['refresh_token'],
      );
      
      // Get current user
      await loadCurrentUser();
      return true;
    } else {
      _error = response.errorMessage;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> loadCurrentUser() async {
    final response = await _authService.getCurrentUser();
    if (response.isSuccess) {
      _currentUser = response.data;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
  
  Future<void> loadChats() async {
    final response = await _chatService.getChats();
    if (response.isSuccess) {
      // Update your chats list
      // _chats = response.data;
      notifyListeners();
    }
  }
}
```

## Testing

To test the API integration before the Laravel backend is ready, you can:

1. Use a mock server like [Mockoon](https://mockoon.com/)
2. Use [json-server](https://github.com/typicode/json-server)
3. Use [Postman Mock Server](https://www.postman.com/features/mock-api/)

Import the Postman collection from `LARAVEL_API_DOCUMENTATION.md` for quick setup.

## Production Checklist

Before deploying to production:

1. ✅ Update `BASE_URL` in `api_config.dart`
2. ✅ Disable/remove logging interceptor in `api_client.dart`
3. ✅ Implement proper SSL pinning
4. ✅ Add proper error tracking (Sentry, Firebase Crashlytics)
5. ✅ Test all API endpoints
6. ✅ Implement proper retry logic for critical operations
7. ✅ Add offline support with local caching
8. ✅ Test token refresh flow
9. ✅ Implement proper loading states
10. ✅ Add analytics tracking

## Common Issues & Solutions

### Issue: 401 Unauthorized after some time
**Solution**: Token has expired. The refresh token flow should handle this automatically. Check your Laravel token expiration settings.

### Issue: CORS errors on web
**Solution**: Configure CORS properly in Laravel backend. Add your Flutter web domain to allowed origins.

### Issue: Timeout errors
**Solution**: Increase timeout values in `api_config.dart` or check your network/server response times.

### Issue: Certificate verification failed
**Solution**: For development with self-signed certificates, you may need to disable SSL verification (NOT recommended for production).

## Support

For Laravel backend implementation, see `LARAVEL_API_DOCUMENTATION.md`.

For API issues:
1. Check the Laravel logs
2. Use the logging interceptor to see request/response data
3. Verify your API endpoint URLs
4. Check your authentication tokens

## Next Steps

1. Implement the Laravel backend following `LARAVEL_API_DOCUMENTATION.md`
2. Test each endpoint using Postman
3. Integrate API calls into your Flutter app screens
4. Add proper loading states and error handling
5. Implement real-time features with WebSockets
6. Add offline support with local database (SQLite/Hive)

Good luck with your VibeChat implementation! 🚀
