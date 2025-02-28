//
//  RecipeListViewModel.swift
//  FetchTakeHomeProject
//
//  Created by Adam Delaney on 2/24/25.
//

import Foundation

@MainActor
class RecipeListViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var errorWrapper: ErrorWrapper?
    @Published var isLoading = false
    
    private let networkManager: NetworkManaging
    
    init(networkManager: NetworkManaging = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func loadRecipes() async {
        isLoading = true
        errorWrapper = nil
        
        do {
            recipes = try await networkManager.fetchRecipes()
        } catch let error as NetworkError {
            errorWrapper = ErrorWrapper(message: error.localizedDescription)
            recipes = []
        } catch {
            errorWrapper = ErrorWrapper(message: "An unexpected error occurred")
            recipes = []
        }
        
        isLoading = false
    }
}
