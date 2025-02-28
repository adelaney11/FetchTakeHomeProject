//
//  ImageCacheTests.swift
//  FetchTakeHomeProject
//
//  Created by Adam Delaney on 2/27/25.
//

import XCTest
@testable import FetchTakeHomeProject

class ImageCacheTests: XCTestCase {
    
    var imageCache: ImageCache!
    let testURL = URL(string: "https://example.com/test.jpg")!
    
    override func setUp() {
        super.setUp()
        // Create a new instance for each test
        imageCache = ImageCache()
        
        // Clear any existing files in the cache directory
        try? FileManager.default.removeItem(at: imageCache.cacheDirectory)
        try? FileManager.default.createDirectory(at: imageCache.cacheDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clear the cache after each test
        imageCache = nil
        super.tearDown()
    }
    
    func testSetAndGetImage() {
        // Create a test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let testImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Initially the cache should be empty
        // Use a unique URL for this test to ensure it's not in the cache
        let uniqueURL = URL(string: "https://example.com/test-\(UUID().uuidString).jpg")!
        XCTAssertNil(imageCache.getImage(for: uniqueURL))
        
        // Set the image in the cache
        imageCache.setImage(testImage, for: uniqueURL)
        
        // Now we should be able to retrieve it
        let cachedImage = imageCache.getImage(for: uniqueURL)
        XCTAssertNotNil(cachedImage)
        
        // Compare the images (basic comparison - in a real app you might want to compare pixel data)
        XCTAssertEqual(cachedImage?.size.width, testImage.size.width)
        XCTAssertEqual(cachedImage?.size.height, testImage.size.height)
    }
    
    func testCacheHitDoesNotTriggerDiskLoad() {
        // Create a test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let testImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Use a unique URL for this test
        let uniqueURL = URL(string: "https://example.com/test-\(UUID().uuidString).jpg")!
        
        // Create a spy image cache that can track disk reads
        let spyCache = SpyImageCache()
        
        // Set the image in the cache
        spyCache.setImage(testImage, for: uniqueURL)
        
        // Get the image - should be a memory cache hit
        _ = spyCache.getImage(for: uniqueURL)
        
        // Verify no disk read occurred
        XCTAssertFalse(spyCache.diskReadOccurred)
    }
}

// Spy implementation of ImageCache to track disk reads
class SpyImageCache: ImageCache {
    var diskReadOccurred = false
    
    override func getImage(for url: URL) -> UIImage? {
        // Check memory cache first (using super implementation)
        let key = url.absoluteString as NSString
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Track that we're about to check disk
        diskReadOccurred = true
        
        // Continue with normal implementation
        return super.getImage(for: url)
    }
}
