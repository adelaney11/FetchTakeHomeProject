//
//  NetworkManagerTests.swift
//  FetchTakeHomeProjectTests
//
//  Created by Adam Delaney on 2/27/25.
//

import XCTest
@testable import FetchTakeHomeProject

final class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkManager = NetworkManager(session: mockURLSession)
    }
    
    override func tearDown() {
        networkManager = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - Test Data
    
    let goodDataURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
    let malformedDataURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!
    let emptyDataURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
    
    let validJSONData = """
    {
        "recipes": [
            {
                "uuid": "eead5f3c-f92b-4c0a-b853-1cb8a8c79e5a",
                "name": "Test Recipe",
                "cuisine": "Italian",
                "photo_url_small": "https://example.com/small.jpg",
                "photo_url_large": "https://example.com/large.jpg",
                "source_url": "https://example.com/recipe",
                "youtube_url": "https://youtube.com/watch"
            }
        ]
    }
    """.data(using: .utf8)!
    
    let malformedJSONData = """
    {
        "recipes": [
            {
                "uuid": "invalid-uuid",
                "cuisine": "Italian",
                "photo_url_small": "https://example.com/small.jpg",
                "photo_url_large": "https://example.com/large.jpg"
            }
        ]
    }
    """.data(using: .utf8)!
    
    let emptyJSONData = """
    {
        "recipes": []
    }
    """.data(using: .utf8)!
    
    // MARK: - Tests
    
    func testFetchRecipesSuccess() async throws {
        // Given
        mockURLSession.data = validJSONData
        mockURLSession.response = HTTPURLResponse(url: goodDataURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When
        let recipes = try await networkManager.fetchRecipes()
        
        // Then
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes[0].name, "Test Recipe")
        XCTAssertEqual(recipes[0].cuisine, "Italian")
    }
    
    func testFetchRecipesEmptyData() async {
        // Given
        mockURLSession.data = emptyJSONData
        mockURLSession.response = HTTPURLResponse(url: emptyDataURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When/Then
        do {
            _ = try await networkManager.fetchRecipes()
            XCTFail("Expected emptyData error")
        } catch NetworkError.emptyData {
            // Success - expected error
        } catch let error as NetworkError {
            if case .decodingFailed(let underlyingError) = error,
               let networkError = underlyingError as? NetworkError,
               case .emptyData = networkError {
                // This is also acceptable - the error might be wrapped
            } else {
                XCTFail("Expected NetworkError.emptyData but got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError.emptyData but got \(error)")
        }
    }
    
    func testFetchRecipesMalformedData() async {
        // Given
        mockURLSession.data = malformedJSONData
        mockURLSession.response = HTTPURLResponse(url: malformedDataURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When/Then
        do {
            _ = try await networkManager.fetchRecipes()
            XCTFail("Expected decodingFailed error")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // Success - expected error
            } else {
                XCTFail("Expected decodingFailed error but got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError.decodingFailed but got \(error)")
        }
    }
    
    func testFetchRecipesRequestFailed() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockURLSession.error = expectedError
        
        // When/Then
        do {
            _ = try await networkManager.fetchRecipes()
            XCTFail("Expected requestFailed error")
        } catch let error as NetworkError {
            if case .requestFailed(let underlyingError) = error {
                XCTAssertEqual((underlyingError as NSError).domain, expectedError.domain)
                XCTAssertEqual((underlyingError as NSError).code, expectedError.code)
            } else {
                XCTFail("Expected requestFailed error but got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError.requestFailed but got \(error)")
        }
    }
    
    func testFetchRecipesInvalidResponse() async {
        // Given
        mockURLSession.data = validJSONData
        mockURLSession.response = HTTPURLResponse(url: goodDataURL, statusCode: 404, httpVersion: nil, headerFields: nil)
        
        // When/Then
        do {
            _ = try await networkManager.fetchRecipes()
            XCTFail("Expected invalidResponse error")
        } catch NetworkError.invalidResponse {
            // Success - expected error
        } catch {
            XCTFail("Expected NetworkError.invalidResponse but got \(error)")
        }
    }
}

// MARK: - Mock URLSession

class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        
        guard let data = data else {
            throw NetworkError.emptyData
        }
        
        guard let response = response else {
            throw NetworkError.invalidResponse
        }
        
        return (data, response)
    }
}
