import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';

/// SendMediaService — uploads a File to POST /api/v1/chats/{id}/messages as
/// multipart with `attachments[]`, then returns the server message row.
///
/// Used by CameraFirstScreen → Chat pipeline: user snaps a photo/video,
/// the file lands directly in the conversation without any intermediate
/// mock storage.  Server-side, the media is hashed (SHA-256) and stored
/// in the LE audit-compliant private tree.
class SendMediaService {
  static final SendMediaService _i = SendMediaService._();
  factory SendMediaService() => _i;
  SendMediaService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(minutes: 3),
    receiveTimeout: const Duration(minutes: 3),
    headers: {'Accept': 'application/json'},
  ));

  Future<Map<String, dynamic>?> sendMedia({
    required String chatId,
    required File file,
    required bool isVideo,
    String? caption,
    String? lensId,
  }) async {
    final token = (await SharedPreferences.getInstance()).getString('access_token') ?? '';
    if (token.isEmpty) return null;

    final form = FormData.fromMap({
      'type': isVideo ? 'video' : 'image',
      if (caption != null && caption.isNotEmpty) 'content': caption,
      if (lensId != null) 'lens_id': lensId,
      'attachments[]': await MultipartFile.fromFile(file.path),
    });

    try {
      final res = await _dio.post('/chats/$chatId/messages',
          data: form,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      return null;
    }
  }
}
