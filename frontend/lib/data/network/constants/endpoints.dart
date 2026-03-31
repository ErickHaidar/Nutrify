class Endpoints {
  Endpoints._();

  // ── Supabase ─────────────────────────────────────────────────────────────
  // TODO: ganti dengan nilai dari Supabase Dashboard → Project Settings → API
  static const String supabaseUrl = 'https://eilxtehpxdnwfxgdgtps.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVpbHh0ZWhweGRud2Z4Z2RndHBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1MTk4NTksImV4cCI6MjA5MDA5NTg1OX0.JWFqVU9en7j9UZW5q5B2wvH-ylOxoMTVF5wVY8HTklA';

  // ── Backend Laravel ───────────────────────────────────────────────────────
  // Android emulator  : http://10.0.2.2:8000/api
  // Perangkat fisik   : http://<IP_LOKAL_KAMU>:8000/api  (cek dengan ipconfig)
  // Ngrok tunnel      : https://flexible-selected-fish.ngrok-free.app/api
  static const String baseUrl = 'https://tobie-unpensioning-melia.ngrok-free.dev/api';

  static const int receiveTimeout = 30000;
  static const int connectionTimeout = 30000;

  // ── API Endpoints (path relatif terhadap baseUrl) ─────────────────────────
  static const String profile = '/profile';
  static const String storeProfile = '/profile/store';
  static const String foods = '/foods';
  static const String foodLogs = '/food-logs';
  static const String foodLogsSummary = '/food-logs/summary';

  // Legacy
  static const String getPosts = '/posts';
}
