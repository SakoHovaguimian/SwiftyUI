
# 🚀 GlowPro Image Engine (`CachedAsyncImage`)

A production-ready, high-performance image caching and rendering engine for SwiftUI. This replaces standard `AsyncImage` to provide memory-safe downsampling, request coalescing, and offline disk caching.

---

## 🧠 How It Works (The 3 Layers)

When a `CachedAsyncImage` appears on screen and requests an image, it flows through three distinct layers to ensure maximum efficiency:

### 1. The RAM Layer (`NSCache`)
The engine first checks `NSCache`. If the image is currently in memory, it returns **instantly** without any decoding or processing. The cache is limited to a configurable size (default 150MB) and automatically evicts the oldest images when the OS is low on memory.

### 2. The Disk Layer (`DiskImageCache`)
If the image isn't in RAM, the engine checks the device's hard drive. 
* To prevent file system errors, the URL and target size are hashed into a safe **SHA-256** string.
* A background janitor automatically deletes images older than 7 days, ensuring the app doesn't balloon in storage size.

### 3. The Network Layer (`RemoteImagePipeline`)
If the image is completely new, it downloads over the network. 
* **Request Coalescing:** If 5 different views ask for the same URL simultaneously, the `RemoteImagePipeline` traps them and only executes **one** network request, distributing the result to all 5 views.
* **Detached Execution:** Network tasks are detached from the UI so that if a user scrolls incredibly fast, the cache still quietly primes itself in the background without dropping half-finished downloads.

---

## 📉 Why This is Memory Efficient (The 10MB Example)

Standard SwiftUI `AsyncImage` pulls an image into memory at its *original* resolution. If your backend sends a massive 10MB (4000x3000) photograph, decoding that into raw pixels costs roughly **48MB of RAM**. If a user scrolls past 10 of these, your app will use 480MB of RAM and crash.

**Our Engine solves this using `ImageIO`:**
1. The 10MB data is downloaded to a temporary buffer.
2. `ImageIO` reads *only the header* of the file, completely avoiding the 48MB decode.
3. It mathematically shrinks the image as it reads the data, targeting your exact UI frame (e.g., 300x300 pixels).
4. The resulting `UIImage` costs only **~3 MB of RAM**. The original 10MB buffer is destroyed.

---

## 🛠 Usage & Snippets

### 1. Basic Image Loading
Always provide a `targetSize` so the engine knows how small to downsample the image.

```swift
CachedAsyncImage(
    url: URL(string: "[https://myapi.com/photo.jpg](https://myapi.com/photo.jpg)")!,
    targetSize: CGSize(width: 300, height: 300)
) {
    ProgressView() // Placeholder
}
.frame(width: 300, height: 300)
