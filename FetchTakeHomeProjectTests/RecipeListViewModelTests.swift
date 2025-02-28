//
//  RecipeListViewModelTests.swift
//  FetchTakeHomeProject
//
//  Created by Adam Delaney on 2/27/25.
//

import XCTest
@testable import FetchTakeHomeProject

class RecipeListViewModelTests: XCTestCase {
    
    @MainActor
    func testLoadRecipesSuccess() async throws {
        // Create a mock network manager that returns successful data
        let mockNetworkManager = MockNetworkManager(shouldSucceed: true)
        let viewModel = RecipeListViewModel(networkManager: mockNetworkManager)
        
        // Initial state check
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorWrapper)
        
        // Load recipes
        await viewModel.loadRecipes()
        
        // Verify state after loading
        XCTAssertFalse(viewModel.recipes.isEmpty)
        XCTAssertEqual(viewModel.recipes.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorWrapper)
        
        // Verify recipe data
        XCTAssertEqual(viewModel.recipes[0].name, "Test Recipe 1")
        XCTAssertEqual(viewModel.recipes[1].name, "Test Recipe 2")
    }
    
    @MainActor
    func testLoadRecipesFailure() async throws {
        // Create a mock network manager that returns an error
        let mockNetworkManager = MockNetworkManager(shouldSucceed: false)
        let viewModel = RecipeListViewModel(networkManager: mockNetworkManager)
        
        // Initial state check
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorWrapper)
        
        // Load recipes
        await viewModel.loadRecipes()
        
        // Verify state after loading
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorWrapper)
        XCTAssertEqual(viewModel.errorWrapper?.message, "Request failed: Mock network error")
    }
}

// Mock NetworkManager for testing
class MockNetworkManager: NetworkManaging {
    private let shouldSucceed: Bool
    
    init(shouldSucceed: Bool) {
        self.shouldSucceed = shouldSucceed
    }
    
    func fetchRecipes() async throws -> [Recipe] {
        if shouldSucceed {
            // Return mock recipes
            return [
                Recipe(id: UUID(), name: "Test Recipe 1", cuisine: "Italian", photoURLSmall: nil, photoURLLarge: nil, sourceURL: nil, youtubeURL: nil),
                Recipe(id: UUID(), name: "Test Recipe 2", cuisine: "Mexican", photoURLSmall: nil, photoURLLarge: nil, sourceURL: nil, youtubeURL: nil)
            ]
        } else {
            // Simulate a network error
            throw NetworkError.requestFailed(NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock network error"]))
        }
    }
}
