//
//  PixelData.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/20/25.
//


//
//  Ext+UIImage.swift
//  Rune
//
//  Created by Sako Hovaguimian on 5/19/25.
//

import SwiftUI

public extension UIImage {
    
    func scaleImage(scaleFactor: CGFloat = 0.05) -> UIImage? {
        
        let newSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let scaledImage = renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return scaledImage
        
    }
    
}

public extension UIImage {
    
    /// Extracts the most prominent and unique colors from a UIImage.
    /// - Parameter numberOfColors: How many clusters (i.e. colors) to return. Defaults to 4.
    /// - Parameter sortByProminence: If `true`, sorts by cluster size (most → least).
    ///                              If `false` (default), sorts by hue (red → violet).
    /// - Throws: An NSError if image resizing or data extraction fails.
    /// - Returns: An array of UIColors.
    func extractColors(numberOfColors k: Int = 4,
                       sortByProminence: Bool = false) throws -> [UIColor] {
        
        // 1️⃣ Get and resize the source CGImage
        guard let srcCG = cgImage else {
            throw NSError(domain: "extractColors", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }
        
        let targetSize = CGSize(
            width: 100,
            height: 100 * size.height / size.width
        )
        
        guard let smallCG = Self.resize(cgImage: srcCG, to: targetSize) else {
            throw NSError(domain: "extractColors", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to resize image"])
        }
        
        // 2️⃣ Turn pixels into [PixelData]
        let pixels = try Self.readPixels(from: smallCG)
        
        // 3️⃣ Run K-means clustering
        let clusters = Self.kMeansCluster(pixels: pixels, k: k)
        
        // 4️⃣ Sort & map → UIColor
        if sortByProminence {
            // most pixels first
            return clusters
                .sorted { $0.points.count > $1.points.count }
                .map { cluster -> UIColor in
                    let c = cluster.center
                    return UIColor(
                        red:   CGFloat(c.red   / 255.0),
                        green: CGFloat(c.green / 255.0),
                        blue:  CGFloat(c.blue  / 255.0),
                        alpha: 1
                    )
                }
        }
        else {
            // rainbow order by hue
            let uiColors = clusters.map { cluster -> UIColor in
                let c = cluster.center
                return UIColor(
                    red:   CGFloat(c.red   / 255.0),
                    green: CGFloat(c.green / 255.0),
                    blue:  CGFloat(c.blue  / 255.0),
                    alpha: 1
                )
            }
            
            // 5️⃣ Sort them by hue and return
            return Self.sortColorsByHue(uiColors)
            
        }
        
    }
    
    // MARK: - Image Resizing
    
    private static func resize(cgImage: CGImage,
                               to size: CGSize) -> CGImage? {
        
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        UIImage(cgImage: cgImage)
            .draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        
    }
    
    // MARK: - Pixel Extraction
    
    private struct PixelData {
        
        var red:   Double
        var green: Double
        var blue:  Double
        
    }
    
    private static func readPixels(from cgImage: CGImage) throws -> [PixelData] {
        
        let width  = cgImage.width
        let height = cgImage.height
        
        // RGBA each 8 bits → 4 bytes per pixel
        let bytesPerPixel    = 4
        let bytesPerRow      = bytesPerPixel * width
        let bitsPerComponent = 8
        
        // Allocate raw memory
        guard let data = calloc(height * width, MemoryLayout<UInt32>.size) else {
            throw NSError(domain: "readPixels", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to allocate memory"])
        }
        defer { free(data) }
        
        // Create a context we can draw into
        guard let ctx = CGContext(
            data: data,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw NSError(domain: "readPixels", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to create CGContext"])
        }
        
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0,
                                     width: width, height: height))
        
        // Peel out pixel triples
        let buffer = data.bindMemory(to: UInt8.self,
                                     capacity: width * height * bytesPerPixel)
        var result: [PixelData] = []
        result.reserveCapacity(width * height)
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = ((width * y) + x) * bytesPerPixel
                let r      = Double(buffer[offset])
                let g      = Double(buffer[offset + 1])
                let b      = Double(buffer[offset + 2])
                
                result.append(.init(red: r, green: g, blue: b))
            }
        }
        
        return result
        
    }
    
    // MARK: - K-Means Clustering
    
    private struct Cluster {
        
        var center: PixelData
        var points: [PixelData]
        
    }
    
    private static func kMeansCluster(pixels: [PixelData],
                                      k: Int,
                                      maxIterations: Int = 10) -> [Cluster] {
        
        // 1️⃣ Initialize centers randomly
        var clusters: [Cluster] = []
        clusters.reserveCapacity(k)
        
        for _ in 0..<k {
            if let rand = pixels.randomElement() {
                clusters.append(.init(center: rand, points: []))
            }
        }
        
        // 2️⃣ Iterate: re-assign points, recompute centers
        for _ in 0..<maxIterations {
            // Clear points
            for i in clusters.indices {
                clusters[i].points.removeAll()
            }
            
            // Assign each pixel to nearest center
            for p in pixels {
                var bestIndex = 0
                var bestDist  = Double.greatestFiniteMagnitude
                
                for (i, c) in clusters.enumerated() {
                    let d = euclideanDistance(between: p, and: c.center)
                    if d < bestDist {
                        bestDist  = d
                        bestIndex = i
                    }
                }
                clusters[bestIndex].points.append(p)
            }
            
            // Recompute centers
            for i in clusters.indices {
                let pts = clusters[i].points
                guard !pts.isEmpty else { continue }
                
                let sum = pts.reduce(into: PixelData(red: 0,
                                                     green: 0,
                                                     blue: 0)) { acc, px in
                    acc.red   += px.red
                    acc.green += px.green
                    acc.blue  += px.blue
                }
                let count = Double(pts.count)
                
                clusters[i].center = .init(
                    red:   sum.red   / count,
                    green: sum.green / count,
                    blue:  sum.blue  / count
                )
            }
        }
        
        return clusters
        
    }
    
    private static func euclideanDistance(between a: PixelData,
                                          and b: PixelData) -> Double {
        
        let dr = a.red   - b.red
        let dg = a.green - b.green
        let db = a.blue  - b.blue
        
        return sqrt(dr * dr + dg * dg + db * db)
        
    }
    
    
    // MARK: - Hue Sorting
    
    private static func sortColorsByHue(_ colors: [UIColor]) -> [UIColor] {
        
        return colors.sorted { c1, c2 in
            
            var h1: CGFloat = 0, s1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
            var h2: CGFloat = 0, s2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
            
            c1.getHue(&h1, saturation: &s1, brightness: &b1, alpha: &a1)
            c2.getHue(&h2, saturation: &s2, brightness: &b2, alpha: &a2)
            
            return h1 < h2
            
        }
        
    }
    
}

//struct ProminentColorsView: View {
//    
//    let uiImage: UIImage
//    @State private var extractedColors: [Color] = []
//    
//    var body: some View {
//        
//        AppBaseView {
//            
//            VStack(spacing: Style.shared.spacing(.medium)) {
//                
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 200)
//                    .cornerRadius(.small)
//                
//                HStack(spacing: 8) {
//                    
//                    ForEach(extractedColors.indices, id: \.self) { idx in
//                        
//                        VStack {
//                            
//                            Rectangle()
//                                .fill(extractedColors[idx])
//                                .frame(width: 40, height: 40)
//                                .cornerRadius(.extraSmall)
//                            
//                            Text(extractedColors[idx].hexStringFromColor())
//                                .appFont(with: .TITLE_1)
//                                .foregroundStyle(.white.opacity(0.75))
//                            
//                        }
//                        
//                    }
//                    
//                }
//                
//            }
//            .onFirstAppear {
//                extractColor()
//            }
//            
//        }
//        
//    }
//    
//    func extractColor() {
//        
//        // Heavy work off the main thread
//        DispatchQueue.global(qos: .userInitiated).async {
//            
//            do {
//                
//                let uiColors = try uiImage.extractColors(
//                    numberOfColors: 5,
//                    sortByProminence: false
//                )
//                
//                let swiftUIColors = uiColors.map { Color($0) }
//                
//                DispatchQueue.main.async {
//                    extractedColors = swiftUIColors
//                }
//                
//            } catch {
//                print("Failed to extract colors:", error)
//            }
//            
//        }
//        
//    }
//    
//}

//#Preview {
//    ProminentColorsView(uiImage: UIImage(resource: .image4))
//}
