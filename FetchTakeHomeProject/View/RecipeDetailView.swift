//
//  RecipeDetailView.swift
//  FetchTakeHomeProject
//
//  Created by Adam Delaney on 2/24/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    private let imageHeight: CGFloat = 250
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CachedAsyncImage(url: recipe.photoURLLarge) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: imageHeight)
                        .clipped()
                        .cornerRadius(10)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: imageHeight)
                        .cornerRadius(10)
                        .overlay {
                            ProgressView()
                        }
                }
                
                // Recipe details
                VStack(alignment: .leading, spacing: 12) {
                    Text(recipe.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Cuisine: \(recipe.cuisine)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // External links
                    if let sourceURL = recipe.sourceURL {
                        Link(destination: sourceURL) {
                            HStack {
                                Image(systemName: "link")
                                Text("View Full Recipe")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if let youtubeURL = recipe.youtubeURL {
                        Link(destination: youtubeURL) {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                Text("Watch on YouTube")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.top)
    }
}
