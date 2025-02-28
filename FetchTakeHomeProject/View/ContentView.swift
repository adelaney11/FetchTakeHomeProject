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
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeRowView(recipe: recipe)
                            }
                        }
                        .transition(.opacity)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        await viewModel.loadRecipes()
                    }
                }
            }
            .navigationTitle("Recipes")
            .task {
                if viewModel.recipes.isEmpty {
                    await viewModel.loadRecipes()
                }
            }
            .alert(item: $viewModel.errorWrapper) { errorWrapper in
                Alert(
                    title: Text("Error"),
                    message: Text(errorWrapper.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
#Preview {
    ContentView()
}
