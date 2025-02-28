//
//  RecipeTests.swift
//  FetchTakeHomeProject
//
//  Created by Adam Delaney on 2/24/25.
//

import XCTest
@testable import FetchTakeHomeProject

class RecipeTests: XCTestCase {
    func testRecipeDecoding() throws {
        let json = """
        {
            "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6",
            "name": "Bakewell Tart",
            "cuisine": "British"
        }
        """.data(using: .utf8)!

        let recipe = try JSONDecoder().decode(Recipe.self, from: json)
        XCTAssertEqual(recipe.name, "Bakewell Tart")
        XCTAssertEqual(recipe.cuisine, "British")
    }
}
