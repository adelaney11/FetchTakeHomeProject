//
//  ContentView.swift
//  FetchTakeHomeProject
//
//  Created by Adam Delaney on 2/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecipeListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading recipes...")
                } else if let errorWrapper = viewModel.errorWrapper {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text(errorWrapper.message)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Button("Try Again") {
                            Task {
                                await viewModel.loadRecipes()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.recipes) { recipe in
                            RecipeRowView(recipe: recipe)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectedRecipe = recipe
                                }
                        }
                        .transition(.opacity)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        await viewModel.loadRecipes()
                    }
                    .sheet(item: $viewModel.selectedRecipe) { recipe in
                        RecipeDetailView(recipe: recipe)
                    }
                }
            }
            .navigationTitle("Recipes")
            .task {
                if viewModel.recipes.isEmpty {
                    await viewModel.loadRecipes()
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
