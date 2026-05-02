// lib/utils/nutrition_tips.dart
// Psychological progress illusion: rotating tips shown during long loads (>1s)

import 'dart:math';

class NutritionTips {
  static const List<String> _tips = [
    '💪 Protein membantu membangun dan memperbaiki jaringan otot.',
    '💧 Minum 8 gelas air sehari membantu metabolisme berjalan optimal.',
    '🥦 Sayuran hijau kaya serat yang menjaga kenyang lebih lama.',
    '🍌 Pisang mengandung kalium yang baik untuk kesehatan jantung.',
    '🏃 30 menit olahraga ringan sehari membakar rata-rata 200 kalori.',
    '🥚 Telur adalah sumber protein lengkap dengan 9 asam amino esensial.',
    '🌾 Karbohidrat kompleks memberi energi tahan lama sepanjang hari.',
    '🫐 Buah beri tinggi antioksidan yang melindungi sel tubuh.',
    '🧘 Tidur 7–8 jam membantu regulasi hormon lapar (ghrelin & leptin).',
    '🥑 Lemak sehat dari alpukat mendukung penyerapan vitamin larut lemak.',
    '🍳 Memasak sendiri membuat kamu lebih sadar kalori yang dikonsumsi.',
    '🌰 Kacang-kacangan mengandung protein, lemak sehat, dan serat tinggi.',
    '🍵 Teh hijau mengandung antioksidan yang mendukung pembakaran lemak.',
    '🍚 Nasi merah punya indeks glikemik lebih rendah dari nasi putih.',
    '⏰ Makan secara teratur mencegah overeating di waktu makan berikutnya.',
    '🐟 Ikan salmon kaya omega-3 yang baik untuk kesehatan otak dan jantung.',
    '🫙 Fermentasi seperti yogurt dan tempe baik untuk kesehatan usus.',
    '🌿 Bumbu rempah seperti jahe dan kunyit memiliki sifat anti-inflamasi.',
  ];

  static final _random = Random();

  /// Returns a single random tip.
  static String getRandomTip() {
    return _tips[_random.nextInt(_tips.length)];
  }

  /// Returns [count] unique random tips (no duplicates).
  static List<String> getRandomTips({int count = 3}) {
    final shuffled = List<String>.from(_tips)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// All tips (for tests and full display).
  static List<String> get all => List.unmodifiable(_tips);
}
