//
//  ImageCache.swift
//  FetchTakeHomeProject
//
//  Created by Adam Delaney on 2/24/25.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    internal let cache = NSCache<NSString, UIImage>()
    internal let fileManager = FileManager.default
    internal let cacheDirectory: URL
    
    init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func getImage(for url: URL) -> UIImage? {
        // Check memory cache first
        let key = url.absoluteString as NSString
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Check disk cache
        let imagePath = cacheDirectory.appendingPathComponent(key.hash.description)
        if let data = try? Data(contentsOf: imagePath),
           let image = UIImage(data: data) {
            // Store in memory cache
            cache.setObject(image, forKey: key)
            return image
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        let key = url.absoluteString as NSString
        
        // Save to memory cache
        cache.setObject(image, forKey: key)
        
        // Save to disk
        let imagePath = cacheDirectory.appendingPathComponent(key.hash.description)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: imagePath)
        }
    }
}
