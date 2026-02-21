# Barangku 📦

Aplikasi personal inventory management untuk iOS. Kelola barang-barangmu dengan mudah menggunakan **deteksi objek otomatis** dari foto via YOLO + CoreML.

## Fitur

- 📸 **Deteksi Otomatis** — Ambil foto barang, AI akan mendeteksi dan mengkategorikan secara otomatis
- 🏷️ **12 Kategori** — Elektronik, Pakaian, Dapur, Furnitur, Buku, Alat, Olahraga, Makanan, Kendaraan, Hewan, Aksesoris, Lainnya
- 🔍 **Cari & Filter** — Cari barang dan filter berdasarkan kategori
- ✏️ **Edit & Hapus** — Edit detail barang kapan saja
- 📱 **SwiftUI + SwiftData** — Fully native iOS dengan data persistence

## Setup: Menambahkan YOLO CoreML Model

Aplikasi ini menggunakan YOLO untuk object detection. Kamu perlu menambahkan model CoreML secara manual:

### Opsi 1: YOLOv3Tiny dari Apple (Rekomendasi)

1. Kunjungi [Apple Machine Learning Models](https://developer.apple.com/machine-learning/models/)
2. Download **YOLOv3TinyInt8LUT.mlmodel** (~35 MB)
3. Drag file `.mlmodel` ke dalam project Xcode (folder `Barangku`)
4. Pastikan "Add to Target: Barangku" dicentang
5. Build dan jalankan!

### Opsi 2: YOLOv8 (Lebih akurat, perlu konversi)

1. Install ultralytics: `pip install ultralytics coremltools`
2. Konversi model:
   ```python
   from ultralytics import YOLO
   model = YOLO('yolov8n.pt')
   model.export(format='coreml', nms=True)
   ```
3. Rename hasil export menjadi `yolov8n.mlmodel`
4. Drag ke project Xcode

### Tanpa Model YOLO

Jika tidak ada model YOLO di bundle, aplikasi akan **otomatis fallback** ke Vision framework built-in classifier (`VNClassifyImageRequest`). Fitur deteksi tetap berjalan, hanya akurasi mungkin berbeda.

## Tech Stack

- **SwiftUI** — UI Framework
- **SwiftData** — Data Persistence
- **CoreML + Vision** — Machine Learning & Object Detection
- **PhotosUI** — Photo Library Access

## Struktur Project

```
Barangku/
├── Models/
│   └── Category.swift          # Enum kategori + warna + ikon
├── Services/
│   ├── ObjectDetectionService.swift  # YOLO/Vision detection
│   └── CategoryMapper.swift    # Label YOLO → Kategori
├── Views/
│   ├── AddItemView.swift       # Form tambah barang
│   ├── ItemDetailView.swift    # Detail & edit barang
│   ├── PhotoPickerView.swift   # Kamera & galeri
│   └── CategoryBadgeView.swift # Badge kategori
├── Item.swift                  # SwiftData model
├── ContentView.swift           # Halaman utama
└── BarangkuApp.swift           # App entry point
```

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 5.9+
