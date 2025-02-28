//
//  NetworkingManager.swift
//  FetchTakeHomeProject
//
//  Created by Adam Delaney on 2/24/25.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case emptyData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingFailed:
            return "Failed to decode data from server"
        case .emptyData:
            return "No recipes available"
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.emptyData, .emptyData):
            return true
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// Add this protocol to make NetworkManager testable
protocol NetworkManaging {
    func fetchRecipes() async throws -> [Recipe]
}

// Update NetworkManager to conform to the protocol
class NetworkManager: NetworkManaging {
    static let shared = NetworkManager()
    
    private let baseURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchRecipes() async throws -> [Recipe] {
        do {
            let (data, response) = try await session.data(from: baseURL)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            do {
                let decodedData = try JSONDecoder().decode(RecipeResponse.self, from: data)
                let recipes = decodedData.recipes
                
                if recipes.isEmpty {
                    throw NetworkError.emptyData
                }
                
                return recipes
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}

struct RecipeResponse: Decodable {
    let recipes: [Recipe]
}

// Protocol for URLSession to make it mockable
protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

// Extension to make URLSession conform to our protocol
extension URLSession: URLSessionProtocol {}
