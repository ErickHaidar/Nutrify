class Endpoints {
  Endpoints._();

  // ── Supabase ─────────────────────────────────────────────────────────────
  // TODO: ganti dengan nilai dari Supabase Dashboard → Project Settings → API
  static const String supabaseUrl = 'https://goifacmbmwmbwxgyqmtk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdvaWZhY21ibXdtYnd4Z3lxbXRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MjcwODAsImV4cCI6MjA4ODMwMzA4MH0.-h1BL265anOF45H_LkT1mZr9_CQVS7_1EmezuHfDMLo';

  // ── Backend Laravel ───────────────────────────────────────────────────────
  // Android emulator  : http://10.0.2.2:8000/api
  // Perangkat fisik   : http://<IP_LOKAL_KAMU>:8000/api  (cek dengan ipconfig)
  // Ngrok tunnel      : https://flexible-selected-fish.ngrok-free.app/api
  static const String baseUrl = 'https://nutrify-app.my.id/api';

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
