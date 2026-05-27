import 'package:dio/dio.dart';

class DioExceptionUtil {
  // general methods:-----------------------------------------------------------
  static String handleError(DioException error) {
    String errorDescription = "Terjadi kesalahan. Silakan coba lagi nanti.";

    // Check if backend returned a specific message in the response body
    if (error.response != null && error.response?.data != null) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['error'] ?? data['msg'] ?? data['error_description'];
        if (message != null && message.toString().isNotEmpty) {
          // Translate or sanitize technical backend messages to friendly Indonesian
          return _mapBackendMessage(message.toString());
        }
      }
    }

    switch (error.type) {
      case DioExceptionType.cancel:
        errorDescription = "Permintaan ke server dibatalkan.";
        break;
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.unknown:
        errorDescription = "Gagal terhubung ke server. Periksa koneksi internet Anda.";
        break;
      case DioExceptionType.receiveTimeout:
        errorDescription = "Waktu tunggu menerima data dari server habis. Silakan coba lagi.";
        break;
      case DioExceptionType.sendTimeout:
        errorDescription = "Waktu tunggu mengirim data ke server habis. Silakan coba lagi.";
        break;
      case DioExceptionType.badCertificate:
        errorDescription = "Sertifikat keamanan tidak valid.";
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          errorDescription = "Permintaan tidak valid. Silakan periksa kembali data Anda.";
        } else if (statusCode == 401) {
          errorDescription = "Sesi Anda telah berakhir atau Anda tidak memiliki akses. Silakan masuk kembali.";
        } else if (statusCode == 403) {
          errorDescription = "Anda tidak memiliki izin untuk melakukan tindakan ini.";
        } else if (statusCode == 404) {
          errorDescription = "Data tidak ditemukan.";
        } else if (statusCode == 429) {
          errorDescription = "Terlalu banyak permintaan. Silakan tunggu beberapa saat.";
        } else if (statusCode != null && statusCode >= 500) {
          errorDescription = "Server sedang mengalami gangguan. Silakan coba beberapa saat lagi.";
        } else {
          errorDescription = "Terjadi kesalahan sistem. Silakan coba lagi nanti.";
        }
        break;
    }
    return errorDescription;
  }

  static String _mapBackendMessage(String message) {
    final lowerMessage = message.toLowerCase();

    // User / Auth related
    if (lowerMessage.contains("email_not_confirmed") || lowerMessage.contains("email not confirmed")) {
      return "Silakan verifikasi email Anda terlebih dahulu.";
    }
    if (lowerMessage.contains("invalid login credentials") || lowerMessage.contains("invalid_credentials") || lowerMessage.contains("invalid username or password")) {
      return "Email atau password salah. Silakan coba lagi.";
    }
    if (lowerMessage.contains("user_already_exists") || lowerMessage.contains("already registered") || lowerMessage.contains("user already registered") || lowerMessage.contains("email already in use")) {
      return "Email ini sudah terdaftar. Silakan gunakan email lain atau masuk.";
    }
    if (lowerMessage.contains("password should be at least") || lowerMessage.contains("weak_password")) {
      return "Kata sandi terlalu lemah. Gunakan minimal 6 karakter.";
    }
    if (lowerMessage.contains("too many requests") || lowerMessage.contains("rate limit") || lowerMessage.contains("rate_limit")) {
      return "Terlalu banyak percobaan. Silakan coba lagi setelah beberapa menit.";
    }
    if (lowerMessage.contains("token expired") || lowerMessage.contains("token_expired") || lowerMessage.contains("jwt expired")) {
      return "Sesi Anda telah berakhir. Silakan masuk kembali.";
    }
    if (lowerMessage.contains("user not found") || lowerMessage.contains("user_not_found")) {
      return "Pengguna tidak ditemukan.";
    }

    // Database / Network / Server
    if (lowerMessage.contains("network error") || lowerMessage.contains("connection failed")) {
      return "Koneksi internet bermasalah. Periksa koneksi Anda.";
    }
    if (lowerMessage.contains("database error") || lowerMessage.contains("internal server error") || lowerMessage.contains("something went wrong")) {
      return "Terjadi kesalahan pada server. Tim kami sedang menanganinya.";
    }

    // Input / Data Validation
    if (lowerMessage.contains("validation failed") || lowerMessage.contains("invalid input")) {
      return "Data yang Anda masukkan tidak valid. Silakan periksa kembali.";
    }
    if (lowerMessage.contains("field required") || lowerMessage.contains("cannot be empty")) {
      return "Harap isi semua kolom yang wajib diisi.";
    }

    // Default fallback to hide technical codes but keeping it human-friendly
    if (RegExp(r'[a-zA-Z0-9_-]+_[a-zA-Z0-9_-]+').hasMatch(message) ||
        lowerMessage.contains("error_code") ||
        lowerMessage.contains("exception")) {
      return "Terjadi kesalahan pada sistem. Silakan hubungi dukungan jika masalah berlanjut.";
    }

    return message;
  }
}

