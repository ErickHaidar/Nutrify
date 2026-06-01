"""Generate Indonesian regional dishes, snacks, and beverages."""
import pandas as pd

REGIONAL_DISHES = [
    # Sumatra Utara / Aceh / Medan
    ("Mie Aceh Goreng", 480, 16, 45, 22, 3, 1000, 2.5),
    ("Mie Aceh Kuah", 450, 15, 42, 20, 3, 950, 2.5),
    ("Nasi Gurih Aceh", 380, 10, 40, 18, 2, 550, 1.5),
    ("Sie Reuboh", 350, 28, 8, 22, 2, 650, 1.0),
    ("Eungkot Paya", 280, 22, 6, 18, 1, 500, 1.0),
    ("Ayam Tangkap", 420, 30, 10, 26, 2, 700, 1.5),
    ("Sambal Ganja", 85, 2, 5, 7, 3, 400, 1.5),
    ("Bika Ambon", 250, 4, 35, 8, 18, 100, 0.5),
    ("Soto Medan", 310, 17, 26, 18, 2, 780, 2.0),
    ("Lontong Medan", 360, 10, 38, 18, 3, 700, 2.5),
    ("Saksang", 380, 26, 8, 28, 2, 600, 1.0),
    ("Dali Ni Horbo", 180, 8, 15, 12, 10, 50, 0.0),

    # Padang / Sumatra Barat
    ("Dendeng Balado", 350, 30, 6, 18, 3, 700, 1.0),
    ("Telur Balado", 180, 12, 5, 12, 3, 400, 0.5),
    ("Ayam Pop", 280, 28, 20, 2, 0.5, 350, 0.0),
    ("Ikan Balado", 250, 22, 5, 15, 2, 550, 0.5),
    ("Udang Balado", 220, 20, 5, 12, 2, 500, 0.5),
    ("Gulai Otak", 280, 14, 5, 22, 1.5, 450, 0.5),
    ("Gulai Tunjang", 320, 18, 5, 25, 1, 480, 0.5),
    ("Gulai Itiak", 350, 24, 5, 26, 1, 500, 1.0),
    ("Sambal Ijo", 85, 1.5, 7, 6, 2, 400, 1.5),
    ("Dendeng Batokok", 340, 30, 8, 17, 3, 680, 1.0),
    ("Soto Padang", 290, 17, 26, 15, 2, 750, 2.0),

    # Palembang / Sumatra Selatan
    ("Pempek Lenjer", 280, 10, 30, 12, 2, 600, 0.5),
    ("Pempek Adaan", 300, 11, 28, 14, 2, 650, 0.5),
    ("Pempek Kulit", 260, 8, 32, 10, 2, 550, 0.5),
    ("Pempek Pistel", 290, 10, 30, 13, 2, 620, 1.0),
    ("Pempek Tahu", 270, 12, 28, 12, 2, 580, 1.0),
    ("Model", 250, 8, 28, 10, 1.5, 500, 0.5),
    ("Tekwan", 220, 8, 25, 9, 1.5, 650, 1.0),
    ("Laksan", 320, 9, 30, 15, 2, 600, 0.5),
    ("Celimpungan", 280, 9, 28, 13, 2, 600, 0.5),
    ("Burgo", 200, 5, 25, 8, 1, 400, 0.5),
    ("Mie Celor", 380, 12, 40, 18, 2, 800, 1.5),
    ("Pindang Iga", 280, 20, 3, 16, 1.5, 500, 0.5),
    ("Pindang Tulang", 240, 18, 3, 14, 1.5, 450, 0.5),
    ("Martabak Har", 380, 14, 32, 22, 3, 700, 1.0),

    # Jambi / Riau
    ("Gulai Ikan Patin", 300, 18, 5, 22, 1, 480, 0.5),
    ("Nasi Gemuk", 340, 8, 40, 16, 1.5, 500, 1.0),

    # Lampung
    ("Seruit", 280, 20, 5, 16, 1, 450, 0.5),
    ("Pindang Serani", 200, 18, 3, 12, 1, 480, 0.5),

    # Betawi / Jakarta
    ("Soto Betawi", 420, 20, 28, 25, 3, 800, 2.0),
    ("Nasi Uduk Betawi", 400, 10, 42, 20, 2, 550, 1.5),
    ("Kerak Telor", 300, 10, 25, 18, 3, 500, 1.0),
    ("Gabus Pucung", 280, 22, 5, 18, 1, 500, 0.5),
    ("Sayur Besan", 150, 4, 12, 10, 2, 350, 2.0),
    ("Semur Jengkol", 250, 12, 18, 14, 5, 550, 3.0),
    ("Pindang Bandeng", 220, 18, 4, 14, 1.5, 480, 0.5),
    ("Pecak Gurame", 250, 20, 5, 16, 1, 450, 0.5),

    # Sunda / Jawa Barat
    ("Nasi Timbel Komplit", 420, 14, 42, 20, 2, 550, 3.0),
    ("Nasi Liwet Sunda", 380, 12, 42, 16, 2, 500, 2.0),
    ("Soto Bandung", 250, 14, 22, 12, 2, 650, 1.5),
    ("Sop Kambing", 350, 20, 10, 24, 1.5, 550, 1.0),
    ("Mie Kocok Bandung", 380, 15, 40, 18, 2, 850, 1.5),
    ("Batagor Bandung", 300, 15, 28, 14, 3, 850, 1.5),
    ("Siomay Bandung", 260, 12, 25, 12, 2.5, 750, 1.5),
    ("Lotek", 300, 10, 25, 16, 4, 400, 4.0),
    ("Karedok", 200, 8, 15, 14, 3, 300, 3.5),
    ("Gepuk", 350, 28, 10, 18, 8, 550, 0.5),
    ("Ayam Goreng Lengkuas", 340, 26, 8, 22, 1, 500, 1.0),
    ("Tahu Gejrot", 180, 6, 18, 10, 5, 400, 1.5),
    ("Surabi Oncom", 200, 6, 28, 10, 2, 250, 1.5),
    ("Surabi Kuah Kinca", 250, 4, 40, 8, 20, 120, 0.5),
    ("Combro", 180, 3, 22, 10, 1, 150, 2.0),
    ("Misro", 190, 2, 30, 8, 12, 100, 1.5),
    ("Colenak", 220, 3, 35, 8, 15, 50, 2.0),
    ("Awug", 250, 3, 45, 6, 18, 80, 1.5),

    # Jawa Tengah / Jogja / Solo
    ("Gudeg Komplit", 450, 14, 48, 22, 15, 600, 4.0),
    ("Nasi Gudeg", 380, 10, 45, 18, 12, 500, 3.5),
    ("Sate Kere", 200, 10, 15, 10, 2, 350, 2.0),
    ("Tengkleng", 320, 18, 8, 22, 2, 550, 1.0),
    ("Soto Kudus", 280, 15, 25, 13, 2, 700, 2.0),
    ("Sop Manten", 250, 12, 20, 14, 2, 500, 2.0),
    ("Mie Ongklok", 350, 10, 42, 15, 3, 750, 1.5),
    ("Nasi Megono", 320, 8, 40, 14, 2, 450, 3.0),
    ("Sego Abang", 280, 6, 42, 10, 1, 350, 2.5),
    ("Garang Asem", 200, 18, 5, 16, 2, 480, 1.0),
    ("Buntil", 180, 12, 10, 14, 2, 400, 3.0),
    ("Botok Tawon", 160, 10, 8, 10, 1.5, 350, 2.5),
    ("Mangut Lele", 280, 18, 5, 20, 2, 500, 1.0),
    ("Sate Klathak", 300, 24, 6, 18, 2, 450, 0.5),
    ("Bakpia", 180, 4, 28, 7, 12, 80, 0.5),
    ("Yangko", 120, 1, 28, 0.5, 14, 5, 0.3),
    ("Geplak", 130, 1.5, 28, 1.5, 20, 10, 0.5),
    ("Jenang", 150, 2, 32, 2, 22, 15, 1.0),
    ("Sego Tempong", 380, 10, 42, 18, 2, 550, 3.0),

    # Jawa Timur / Surabaya / Malang
    ("Rawon", 320, 20, 25, 16, 2, 700, 2.5),
    ("Soto Lamongan", 285, 16, 25, 14, 2, 710, 2.0),
    ("Soto Madura", 310, 17, 26, 15, 2, 740, 2.0),
    ("Rujak Cingur", 250, 10, 25, 12, 5, 450, 3.0),
    ("Tahu Campur", 320, 12, 30, 16, 3, 700, 2.5),
    ("Tahu Tek", 300, 10, 32, 14, 4, 650, 2.0),
    ("Lontong Balap", 280, 8, 32, 12, 3, 550, 2.0),
    ("Lontong Kupang", 250, 12, 30, 10, 2, 500, 2.0),
    ("Semanggi", 180, 5, 20, 10, 3, 400, 2.5),
    ("Pecel Madiun", 320, 10, 30, 17, 4, 420, 4.5),
    ("Pecel Tumpang", 350, 12, 28, 20, 3, 500, 4.0),
    ("Nasi Krawu", 420, 14, 50, 20, 3, 750, 2.5),
    ("Nasi Becek", 380, 16, 42, 18, 2, 650, 2.0),
    ("Sate Ponorogo", 260, 21, 7, 16, 3.5, 420, 1.0),
    ("Bakso Malang", 320, 16, 32, 14, 2.5, 1000, 2.0),
    ("Cwie Mie", 400, 14, 45, 18, 2.5, 850, 1.5),

    # Kalimantan
    ("Soto Banjar", 295, 16, 24, 14.5, 2, 730, 2.0),
    ("Ketupat Kandangan", 350, 12, 38, 16, 2, 600, 1.5),
    ("Nasi Kuning Banjar", 350, 10, 42, 15, 2, 500, 1.5),
    ("Sate Banjar", 240, 18, 5, 16, 2, 400, 0.5),
    ("Iwak Pakasam", 200, 18, 2, 14, 0.5, 500, 0.5),
    ("Gangan Asam", 180, 15, 3, 12, 1, 450, 1.0),
    ("Nasi Bekepor", 380, 14, 40, 18, 1.5, 500, 1.5),

    # Sulawesi
    ("Coto Makassar", 350, 20, 26, 18, 2, 800, 2.5),
    ("Konro", 380, 24, 8, 24, 1.5, 650, 1.0),
    ("Pallubasa", 340, 18, 8, 22, 1.5, 700, 1.0),
    ("Pisang Epe", 200, 1, 38, 6, 18, 30, 2.0),
    ("Es Pisang Ijo", 280, 3, 48, 10, 28, 50, 2.0),
    ("Sop Konro", 350, 22, 6, 24, 1, 600, 1.0),
    ("Nasi Jaha", 320, 6, 50, 10, 2, 350, 2.0),
    ("Tinutuan", 180, 5, 30, 6, 3, 300, 4.0),
    ("Mie Cakalang", 400, 14, 45, 18, 2.5, 800, 1.5),
    ("Panada", 250, 6, 30, 12, 2, 350, 1.0),
    ("Klappertart", 280, 5, 35, 14, 22, 100, 1.0),
    ("Ayam Rica-Rica", 300, 28, 5, 18, 2, 600, 1.5),
    ("Ikan Woku", 280, 22, 5, 17, 2, 550, 1.5),
    ("Dabu-Dabu", 45, 1, 3, 3.5, 1.5, 250, 1.5),

    # Bali / Nusa Tenggara
    ("Ayam Betutu", 300, 29, 6, 18, 2, 550, 1.5),
    ("Bebek Betutu", 350, 26, 8, 22, 2, 600, 1.5),
    ("Sate Lilit", 240, 19, 5, 16, 2, 380, 1.0),
    ("Lawar", 200, 14, 5, 14, 1.5, 350, 2.5),
    ("Nasi Jinggo", 350, 10, 42, 16, 2, 550, 1.5),
    ("Tipat Cantok", 250, 8, 32, 10, 3, 350, 3.0),
    ("Serombotan", 180, 6, 20, 10, 3, 300, 3.5),
    ("Sate Bulayak", 260, 18, 14, 16, 2, 450, 1.5),
    ("Ayam Taliwang", 320, 30, 4, 20, 2, 650, 1.0),
    ("Pelecing Kangkung", 120, 5, 10, 8, 2, 400, 2.5),
    ("Sate Rembiga", 270, 22, 6, 17, 2, 480, 1.0),
    ("Ares", 180, 14, 5, 12, 2, 350, 2.0),
    ("Jaje Uli", 200, 3, 38, 5, 10, 50, 1.0),
    ("Rujak Bulung", 120, 4, 18, 4, 8, 300, 3.0),

    # Papua / Maluku
    ("Ikan Kuah Kuning", 250, 20, 5, 16, 1.5, 500, 1.0),
    ("Papeda", 150, 1, 35, 0.5, 0.1, 5, 0.5),
    ("Ikan Bungkus", 220, 20, 4, 14, 1, 400, 1.0),
    ("Sate Ulat Sagu", 180, 8, 5, 15, 1, 250, 3.0),

    # Minuman Indonesia
    ("Es Doger", 280, 3, 45, 12, 32, 60, 2.0),
    ("Es Goyobod", 260, 2, 48, 8, 28, 40, 1.5),
    ("Es Selendang Mayang", 300, 3, 52, 10, 35, 50, 1.0),
    ("Es Oyen", 270, 4, 42, 12, 30, 45, 2.0),
    ("Es Kacang Ijo", 280, 8, 48, 5, 30, 35, 3.0),
    ("Es Palu Butung", 240, 2, 42, 8, 28, 30, 1.5),
    ("Es Lidah Buaya", 180, 1, 40, 2, 25, 20, 2.0),
    ("Es Kopyor", 220, 2, 30, 12, 20, 60, 1.5),
    ("Es Puter", 180, 3, 28, 8, 22, 40, 0.0),
    ("Bajigur", 180, 2, 28, 6, 20, 30, 0.5),
    ("Bandrek", 120, 1, 25, 1, 18, 15, 1.0),
    ("Wedang Ronde", 200, 3, 35, 5, 25, 20, 1.5),
    ("Wedang Uwuh", 60, 0.5, 14, 0.5, 10, 10, 1.0),
    ("Wedang Secang", 70, 0.5, 16, 0.5, 12, 10, 1.0),
    ("Bir Pletok", 90, 1, 20, 0.5, 15, 15, 1.5),
    ("STMJ", 250, 8, 32, 10, 22, 60, 0.5),
    ("Susu Jahe", 180, 8, 20, 8, 18, 40, 0.0),
    ("Kopi Aceh", 5, 0.2, 1, 0.0, 0.0, 5, 0.0),
    ("Kopi Tubruk", 4, 0.2, 0.5, 0.0, 0.0, 3, 0.0),
    ("Kopi Luwak", 5, 0.3, 0.5, 0.0, 0.0, 3, 0.0),

    # Camilan tambahan
    ("Tahu Walik", 200, 10, 15, 12, 1.5, 250, 1.0),
    ("Tahu Bulat", 220, 11, 18, 14, 1, 220, 1.0),
    ("Cimol", 180, 2, 25, 8, 2, 200, 1.5),
    ("Cilung", 160, 2, 20, 8, 2, 180, 1.0),
    ("Cilor", 200, 6, 22, 10, 2, 250, 1.0),
    ("Telur Gulung", 200, 10, 15, 13, 1.5, 250, 1.0),
    ("Sempol", 180, 8, 18, 10, 1.5, 300, 1.0),
    ("Maklor", 190, 5, 22, 10, 1.5, 200, 1.0),
    ("Cireng Isi", 220, 5, 28, 10, 1.5, 220, 1.5),
    ("Pisang Molen", 200, 2, 28, 9, 10, 50, 1.0),
    ("Pisang Aroma", 190, 2, 26, 9, 10, 50, 1.0),
    ("Tela-Tela", 220, 1.5, 36, 8, 2, 100, 2.0),
    ("Kentang Goreng Tepung", 310, 4, 38, 16, 1, 200, 3.0),
    ("Kentang Spiral", 290, 3.5, 36, 15, 1, 250, 3.0),
    ("Tahu Crispy", 230, 9, 16, 15, 1, 220, 1.0),
    ("Jamur Crispy", 210, 5, 16, 14, 1, 200, 2.0),
    ("Terong Crispy", 200, 3, 18, 13, 1.5, 200, 2.0),
    ("Pangsit Goreng", 220, 8, 22, 13, 1, 350, 0.5),
    ("Siomay Goreng", 230, 10, 24, 12, 2, 500, 1.0),
    ("Tahu Sumedang", 250, 10, 18, 15, 1, 200, 1.0),
    ("Peyek Kacang", 120, 5, 10, 8, 0.5, 100, 1.0),
    ("Peyek Teri", 130, 7, 10, 8, 0.5, 250, 1.0),
    ("Peyek Udang", 140, 8, 10, 9, 0.5, 200, 1.0),
    ("Emping Melinjo", 100, 3, 12, 5, 1, 150, 2.0),
    ("Kacang Bawang", 300, 12, 18, 22, 2, 200, 5.0),
    ("Kacang Telur", 320, 14, 20, 24, 3, 250, 4.0),
    ("Rempeyek", 100, 4, 12, 5, 0.5, 180, 1.0),

    # Makanan mahasiswa tambahan
    ("Nasi Sarden", 380, 14, 42, 18, 2, 700, 1.5),
    ("Nasi Kornet", 420, 12, 44, 22, 2, 800, 1.0),
    ("Nasi Abon", 350, 10, 40, 16, 2, 550, 1.0),
    ("Nasi Kecap Telur", 350, 12, 40, 16, 5, 600, 0.8),
    ("Roti Lapis Telur", 320, 14, 35, 14, 3, 500, 2.0),
    ("Sandwich Sederhana", 300, 12, 35, 12, 3, 450, 2.5),
    ("Salad Sayur Sederhana", 120, 4, 10, 7, 3, 150, 3.5),
    ("Salad Buah", 180, 2, 35, 4, 25, 10, 3.0),
    ("Nasi Ayam Katsu", 500, 22, 48, 24, 2, 650, 1.5),
    ("Nasi Ayam Teriyaki", 480, 24, 48, 20, 6, 700, 1.5),
    ("Nasi Daging Teriyaki", 500, 26, 46, 22, 6, 750, 1.5),
    ("Chicken Katsu Curry", 520, 24, 48, 26, 3, 750, 2.0),
    ("Nasi Telur Orak-Arik", 350, 14, 40, 15, 1, 300, 1.0),
    ("Bubur Instan", 150, 3, 28, 3, 4, 450, 1.5),
    ("Oatmeal", 160, 5, 27, 3, 1, 2, 4.0),
    ("Oatmeal Pisang", 220, 6, 38, 4, 8, 5, 5.0),
    ("Granola Susu", 280, 8, 40, 10, 12, 40, 5.0),
    ("Sereal Susu", 250, 7, 42, 8, 14, 150, 3.0),
    ("Nasi Nugget", 420, 10, 45, 22, 2, 700, 1.0),
    ("Nasi Sosis", 400, 10, 42, 20, 2, 750, 1.0),
    ("Kentang Tumbuh", 150, 3, 25, 4, 1, 200, 3.0),
    ("Bubur Manado", 180, 5, 30, 5, 2, 350, 3.5),

    # Makanan modern / fusion
    ("Nasi Rendang", 520, 26, 45, 28, 3, 650, 2.0),
    ("Nasi Gulai", 450, 20, 42, 24, 2, 550, 1.5),
    ("Nasi Opor", 420, 22, 42, 20, 2, 500, 1.0),
    ("Mie Rendang", 520, 22, 48, 28, 3, 700, 2.0),
    ("Nasi Kebuli", 480, 20, 46, 24, 3, 600, 1.5),
    ("Nasi Mandhi", 460, 22, 44, 22, 2, 550, 1.5),
    ("Nasi Biryani", 490, 22, 46, 24, 3, 600, 2.0),
    ("Nasi Hainan", 380, 14, 42, 16, 1, 400, 1.0),
    ("Nasi Tim Ayam", 350, 18, 38, 14, 1.5, 500, 1.5),
    ("Nasi Campur Bali", 480, 20, 48, 24, 3, 750, 2.5),
    ("Nasi Campur Manado", 460, 22, 46, 22, 3, 700, 2.5),
    ("Ikan Woku Daun Kemangi", 290, 23, 5, 17, 2, 560, 1.5),
    ("Ayam Woku Daun Kemangi", 310, 28, 6, 19, 2, 580, 1.5),
    ("Tuna Sambal Matah", 200, 25, 4, 5, 2, 350, 1.5),
    ("Ayam Sambal Matah", 280, 27, 5, 16, 2, 380, 1.5),
    ("Sop Buntut Goreng", 420, 24, 15, 28, 2, 550, 1.5),
    ("Iga Bakar", 450, 28, 12, 28, 3, 600, 0.5),
    ("Iga Penyet", 480, 26, 18, 30, 2, 700, 1.0),
    ("Bebek Goreng", 380, 24, 5, 26, 1, 500, 0.5),
    ("Bebek Penyet", 420, 25, 15, 28, 2, 650, 1.0),
    ("Gurame Goreng Tepung", 350, 20, 15, 22, 1, 400, 0.5),
    ("Gurame Asam Manis", 300, 18, 12, 18, 8, 450, 0.5),
    ("Kakap Goreng Tepung", 340, 20, 15, 20, 1, 380, 0.5),
    ("Udang Saus Padang", 280, 20, 8, 16, 3, 600, 0.5),
    ("Udang Saus Tiram", 260, 20, 5, 15, 2, 550, 0.5),
    ("Cumi Saus Padang", 270, 18, 7, 17, 3, 580, 0.5),
    ("Cumi Asam Manis", 240, 16, 8, 15, 7, 500, 0.5),
    ("Kerang Saus Padang", 250, 16, 7, 18, 2, 550, 1.0),
]


def generate():
    foods = []
    seen = set()
    for name, cal, prot, carb, fat, sugar, sodium, fiber in REGIONAL_DISHES:
        key = name.lower().strip()
        if key in seen:
            continue
        seen.add(key)
        foods.append({
            "name": name, "name_id": name, "serving_size": "1 porsi",
            "calories": cal, "protein_g": prot, "carbohydrate_g": carb,
            "fat_g": fat, "sugar_g": sugar, "sodium_mg": sodium, "fiber_g": fiber,
            "food_type": "local_indonesian", "source": "generated-regional",
        })
    return foods


if __name__ == "__main__":
    foods = generate()
    df = pd.DataFrame(foods)
    import os
    out = os.path.join(os.path.dirname(__file__), "output", "generated_regional.csv")
    df.to_csv(out, index=False)
    print(f"Generated {len(foods)} regional foods -> {out}")
