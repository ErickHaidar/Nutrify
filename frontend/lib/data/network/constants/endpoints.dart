import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoints {
  Endpoints._();

  // ── Supabase (Ambil dari .env) ───────────────────────────────────────────
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // ── Backend Laravel (Ambil dari .env) ──────────────────────────────────
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? 'https://nutrify-app.my.id/api/';
    return url.endsWith('/') ? url : '$url/';
  }

  static int get receiveTimeout => int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '') ?? 30000;
  static int get connectionTimeout => int.tryParse(dotenv.env['CONNECTION_TIMEOUT'] ?? '') ?? 30000;

  // ── API Endpoints (path relatif terhadap baseUrl) ─────────────────────────
  static const String profile = 'profile';
  static const String profilePhoto = 'profile/photo';
  static const String storeProfile = 'profile/store';
  static const String foods = 'foods';
  static const String foodLogs = 'food-logs';
  static const String foodLogsSummary = 'food-logs/summary';
  static const String foodFavorites = 'food/favorites';
  static const String foodRecommendations = 'food/recommendations';
  static const String posts = 'posts';
  static const String notifications = 'notifications';
  static const String chatConversations = 'chat/conversations';
  static const String chatUnreadCount = 'chat/unread-count';

  // Legacy
  static const String getPosts = '/posts';
}
