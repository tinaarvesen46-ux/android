# VibeChat Laravel Backend API Documentation

## Overview
This document provides comprehensive API specifications for the VibeChat Laravel backend. The Flutter app expects these endpoints to be implemented with Laravel Sanctum authentication.

## Base URL
```
https://api.vibechat.one/api/v1
```

## Authentication
All protected endpoints require Bearer token authentication:
```
Authorization: Bearer {access_token}
```

## Response Format
All responses should follow this format:

### Success Response
```json
{
  "success": true,
  "message": "Success message",
  "data": {}
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field_name": ["Error message 1", "Error message 2"]
  }
}
```

### Paginated Response
```json
{
  "success": true,
  "data": [],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 100,
    "last_page": 5
  },
  "links": {
    "first": "url",
    "last": "url",
    "prev": null,
    "next": "url"
  }
}
```

---

## Authentication Endpoints

### POST /auth/login
Login with email/username and password

**Request:**
```json
{
  "identifier": "username or email",
  "password": "password123",
  "device_name": "mobile"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "access_token": "token_here",
    "refresh_token": "refresh_token_here",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": "uuid",
      "username": "john_doe",
      "display_name": "John Doe",
      "email": "john@example.com",
      "avatar_url": "https://...",
      "is_verified": true,
      ...
    }
  }
}
```

### POST /auth/register
Register a new user

**Request:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "display_name": "John Doe",
  "date_of_birth": "2000-01-01T00:00:00.000Z",
  "accept_terms": true
}
```

**Response:** Same as login

### POST /auth/logout
Logout current user (revoke token)

**Headers:** Authorization: Bearer {token}

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### POST /auth/refresh
Refresh access token

**Request:**
```json
{
  "refresh_token": "refresh_token_here"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "new_token_here",
    "refresh_token": "new_refresh_token_here",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

### POST /auth/forgot-password
Send password reset email

**Request:**
```json
{
  "email": "john@example.com"
}
```

### POST /auth/reset-password
Reset password with token

**Request:**
```json
{
  "email": "john@example.com",
  "token": "reset_token",
  "password": "new_password",
  "password_confirmation": "new_password"
}
```

### POST /auth/verify-email
Verify email with token

**Request:**
```json
{
  "token": "verification_token"
}
```

---

## User Endpoints

### GET /users/me
Get current authenticated user

**Headers:** Authorization: Bearer {token}

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "john_doe",
    "display_name": "John Doe",
    "email": "john@example.com",
    "avatar_url": "https://...",
    "cover_url": "https://...",
    "bio": "My bio",
    "pronouns": "he/him",
    "location": "New York",
    "is_verified": true,
    "is_online": true,
    "last_seen": "2026-01-15T10:30:00.000Z",
    "account_status": "creator",
    "privacy_level": "public",
    "staff_role": "administrator",
    "friend_count": 150,
    "streak_days": 7,
    "is_favorite": false,
    "is_close_friend": false
  }
}
```

### GET /users/{userId}
Get user by ID

**Response:** Same as /users/me

### PATCH /users/me
Update current user profile

**Request:**
```json
{
  "display_name": "John Doe",
  "bio": "Updated bio",
  "pronouns": "he/him",
  "location": "New York",
  "privacy_level": "friends_only"
}
```

**Response:** Updated user object

### POST /users/me/avatar
Upload avatar

**Request:** multipart/form-data
- avatar: File

**Response:**
```json
{
  "success": true,
  "data": {
    "avatar_url": "https://..."
  }
}
```

### POST /users/me/cover
Upload cover photo

**Request:** multipart/form-data
- cover: File

**Response:**
```json
{
  "success": true,
  "data": {
    "cover_url": "https://..."
  }
}
```

### GET /search/users
Search users

**Query Parameters:**
- query: string (required)
- page: integer (default: 1)
- per_page: integer (default: 20)

**Response:**
```json
{
  "success": true,
  "data": [user_objects],
  "meta": {...}
}
```

### GET /search/discover
Get discover users

**Query Parameters:**
- page: integer (default: 1)
- per_page: integer (default: 20)

**Response:** Same as search users

### POST /users/{userId}/block
Block user

### DELETE /users/{userId}/unblock
Unblock user

### GET /users/blocked
Get blocked users list

---

## Chat Endpoints

### GET /chats
Get all chats for current user

**Query Parameters:**
- page: integer (default: 1)
- per_page: integer (default: 50)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "participant": {user_object},
      "last_message": {message_object},
      "is_pinned": false,
      "is_muted": false,
      "unread_count": 3,
      "disappearing_enabled": false,
      "disappearing_duration": null,
      "screenshot_disabled": false,
      "updated_at": "2026-01-15T10:30:00.000Z"
    }
  ],
  "meta": {...}
}
```

### GET /chats/{chatId}
Get specific chat

### GET /chats/{chatId}/messages
Get messages for a chat

**Query Parameters:**
- page: integer (default: 1)
- per_page: integer (default: 50)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "sender_id": "uuid",
      "content": "Hello!",
      "timestamp": "2026-01-15T10:30:00.000Z",
      "type": "text",
      "status": "delivered",
      "is_read": false,
      "media_url": null,
      "expiration": "keep_forever",
      "view_duration": null,
      "reply_to_id": null,
      "reactions": [],
      "is_edited": false,
      "edited_at": null
    }
  ],
  "meta": {...}
}
```

### POST /chats/{chatId}/messages
Send message

**Request:**
```json
{
  "content": "Hello!",
  "type": "text",
  "media_url": "https://...",
  "reply_to_id": "uuid",
  "expiration": "keep_forever",
  "view_duration": null
}
```

**Response:** Created message object

### PATCH /messages/{messageId}
Edit message

**Request:**
```json
{
  "content": "Updated message"
}
```

### DELETE /messages/{messageId}
Delete message

### POST /messages/{messageId}/react
React to message

**Request:**
```json
{
  "emoji": "❤️"
}
```

### POST /chats/{chatId}/read
Mark chat as read

---

## Story Endpoints

### GET /stories
Get all stories from friends

**Query Parameters:**
- page: integer (default: 1)
- per_page: integer (default: 50)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "user": {user_object},
      "media_url": "https://...",
      "type": "image",
      "caption": "My story",
      "audience": "friends",
      "views_count": 45,
      "has_viewed": true,
      "created_at": "2026-01-15T10:30:00.000Z",
      "expires_at": "2026-01-16T10:30:00.000Z"
    }
  ],
  "meta": {...}
}
```

### POST /stories
Create new story

**Request:**
```json
{
  "media_url": "https://...",
  "type": "image",
  "caption": "My story",
  "audience": "friends",
  "duration_hours": 24
}
```

**Response:** Created story object

### GET /stories/{storyId}
Get story by ID

### DELETE /stories/{storyId}
Delete story

### POST /stories/{storyId}/view
Mark story as viewed

### GET /stories/{storyId}/viewers
Get story viewers

---

## Friend Endpoints

### GET /friends
Get friends list

**Query Parameters:**
- page: integer (default: 1)
- per_page: integer (default: 50)

**Response:**
```json
{
  "success": true,
  "data": [user_objects],
  "meta": {...}
}
```

### GET /friend-requests
Get friend requests

**Query Parameters:**
- type: string (received, sent, all) (default: received)
- page: integer (default: 1)
- per_page: integer (default: 50)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "sender": {user_object},
      "receiver": {user_object},
      "status": "pending",
      "created_at": "2026-01-15T10:30:00.000Z"
    }
  ],
  "meta": {...}
}
```

### POST /friend-requests/send/{userId}
Send friend request

### POST /friend-requests/{requestId}/accept
Accept friend request

### POST /friend-requests/{requestId}/reject
Reject friend request

### DELETE /friend-requests/{requestId}/cancel
Cancel friend request

### DELETE /friends/{userId}
Unfriend user

---

## Settings Endpoints

### GET /settings/privacy
Get privacy settings

### PATCH /settings/privacy
Update privacy settings

**Request:**
```json
{
  "profile_visibility": "public",
  "story_visibility": "friends",
  "last_seen_visibility": "everyone",
  "read_receipts": true,
  "typing_indicators": true
}
```

### GET /settings/security
Get security settings

### GET /settings/notifications
Get notification settings

### GET /settings/appearance
Get appearance settings

### POST /settings/password
Change password

**Request:**
```json
{
  "current_password": "old_password",
  "new_password": "new_password",
  "new_password_confirmation": "new_password"
}
```

### POST /settings/2fa/enable
Enable 2FA

**Response:**
```json
{
  "success": true,
  "data": {
    "qr_code": "data:image/png;base64,...",
    "secret": "SECRET_KEY",
    "recovery_codes": ["code1", "code2", ...]
  }
}
```

### POST /settings/2fa/verify
Verify 2FA code

**Request:**
```json
{
  "code": "123456"
}
```

### POST /settings/2fa/disable
Disable 2FA

**Request:**
```json
{
  "password": "user_password"
}
```

---

## Security Endpoints

### GET /security/login-history
Get login history

**Query Parameters:**
- page: integer (default: 1)
- per_page: integer (default: 20)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "device": "iPhone 13",
      "location": "New York, US",
      "ip_address": "192.168.1.1",
      "user_agent": "...",
      "logged_in_at": "2026-01-15T10:30:00.000Z"
    }
  ],
  "meta": {...}
}
```

### GET /security/sessions
Get active sessions

### DELETE /security/sessions/{sessionId}
Revoke session

### GET /security/suspicious-activity
Get suspicious activity

### POST /security/export-data
Export user data (GDPR)

**Response:**
```json
{
  "success": true,
  "data": {
    "export_id": "uuid",
    "status": "processing",
    "download_url": null,
    "expires_at": null
  }
}
```

### DELETE /security/delete-account
Delete account

**Request:**
```json
{
  "password": "user_password",
  "reason": "Optional reason"
}
```

---

## Media Endpoints

### POST /media/upload
Upload media file

**Request:** multipart/form-data
- media: File
- type: string (image, video, voice)
- for: string (message, story, profile)

**Response:**
```json
{
  "success": true,
  "data": {
    "media_id": "uuid",
    "media_url": "https://...",
    "media_type": "image",
    "file_size": 1024000,
    "duration": null
  }
}
```

### GET /media/{mediaId}
Get media by ID

### DELETE /media/{mediaId}
Delete media

---

## Database Schema Recommendations

### users table
```sql
- id (uuid, primary)
- username (string, unique)
- email (string, unique)
- password (string, hashed)
- display_name (string)
- avatar_url (string, nullable)
- cover_url (string, nullable)
- bio (text, nullable)
- pronouns (string, nullable)
- location (string, nullable)
- date_of_birth (date)
- is_verified (boolean, default false)
- is_online (boolean, default false)
- last_seen (timestamp, nullable)
- account_status (enum: normal, verified, creator)
- privacy_level (enum: public, friends_only, private)
- staff_role (enum: none, support, moderator, administrator)
- streak_days (integer, default 0)
- email_verified_at (timestamp, nullable)
- two_factor_secret (string, nullable)
- two_factor_recovery_codes (text, nullable)
- created_at (timestamp)
- updated_at (timestamp)
- deleted_at (timestamp, nullable)
```

### chats table
```sql
- id (uuid, primary)
- user1_id (uuid, foreign)
- user2_id (uuid, foreign)
- is_pinned_user1 (boolean, default false)
- is_pinned_user2 (boolean, default false)
- is_muted_user1 (boolean, default false)
- is_muted_user2 (boolean, default false)
- disappearing_enabled (boolean, default false)
- disappearing_duration (integer, nullable)
- screenshot_disabled (boolean, default false)
- created_at (timestamp)
- updated_at (timestamp)
```

### messages table
```sql
- id (uuid, primary)
- chat_id (uuid, foreign)
- sender_id (uuid, foreign)
- content (text)
- type (enum: text, image, video, voice, gif)
- status (enum: sending, sent, delivered, read, failed)
- media_url (string, nullable)
- expiration (enum: view_once, timed_view, keep_forever)
- view_duration (integer, nullable)
- reply_to_id (uuid, nullable, foreign)
- is_edited (boolean, default false)
- edited_at (timestamp, nullable)
- created_at (timestamp)
- updated_at (timestamp)
- deleted_at (timestamp, nullable)
```

### stories table
```sql
- id (uuid, primary)
- user_id (uuid, foreign)
- media_url (string)
- type (enum: image, video)
- caption (text, nullable)
- audience (enum: public, friends, custom)
- views_count (integer, default 0)
- created_at (timestamp)
- expires_at (timestamp)
```

### story_views table
```sql
- id (uuid, primary)
- story_id (uuid, foreign)
- viewer_id (uuid, foreign)
- viewed_at (timestamp)
```

### friendships table
```sql
- id (uuid, primary)
- user1_id (uuid, foreign)
- user2_id (uuid, foreign)
- is_favorite_user1 (boolean, default false)
- is_favorite_user2 (boolean, default false)
- is_close_friend_user1 (boolean, default false)
- is_close_friend_user2 (boolean, default false)
- created_at (timestamp)
```

### friend_requests table
```sql
- id (uuid, primary)
- sender_id (uuid, foreign)
- receiver_id (uuid, foreign)
- status (enum: pending, accepted, rejected)
- created_at (timestamp)
- updated_at (timestamp)
```

---

## Notes for Laravel Developers

1. **Use Laravel Sanctum** for API authentication
2. **Implement rate limiting** on sensitive endpoints (login, register, password reset)
3. **Use Laravel queues** for async operations (media processing, email sending, data exports)
4. **Implement WebSockets** using Laravel Echo and Pusher/Redis for real-time features
5. **Use Laravel storage** with S3 or similar for media files
6. **Implement proper validation** using Form Requests
7. **Use API Resources** for consistent response formatting
8. **Add proper logging** for debugging and security monitoring
9. **Implement CORS** properly for Flutter web support
10. **Use database transactions** for critical operations (friend requests, payments)
11. **Implement soft deletes** for GDPR compliance
12. **Add database indexes** on frequently queried fields (user_id, chat_id, created_at)
13. **Use Laravel Horizon** for queue monitoring
14. **Implement proper error handling** with try-catch blocks
15. **Use Laravel Telescope** for development debugging

## Security Best Practices

1. Hash passwords using bcrypt (Laravel default)
2. Validate all input data
3. Sanitize output to prevent XSS
4. Use HTTPS only
5. Implement CSRF protection
6. Rate limit sensitive endpoints
7. Log suspicious activities
8. Implement proper session management
9. Use secure token generation
10. Implement 2FA for sensitive operations
11. Regular security audits
12. Keep Laravel and dependencies updated

## Testing

Implement comprehensive tests:
- Unit tests for models and services
- Feature tests for API endpoints
- Integration tests for complex flows
- Load testing for scalability

## Deployment

Recommended infrastructure:
- Laravel Forge or AWS EC2 for hosting
- Redis for caching and queues
- MySQL/PostgreSQL for database
- S3 for media storage
- CloudFlare for CDN and DDoS protection
- Laravel Horizon for queue monitoring
- Sentry for error tracking
