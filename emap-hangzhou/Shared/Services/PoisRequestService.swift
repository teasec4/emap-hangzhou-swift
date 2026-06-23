//
//  PoisRequestService.swift
//  emap-hangzhou
//
//  Created by Максим Ковалев on 6/23/26.
//

import Foundation

class PoisRequestService {
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: String = "https://content.nalichi.fun",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    /// Fetch all public POIs from the server.
    func fetchPlaces() async throws -> [ServerPlace] {
        guard let url = URL(string: "\(baseURL)/api/public/pois") else {
            throw ServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw ServiceError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try decoder.decode([ServerPlace].self, from: data)
        } catch {
            throw ServiceError.decodingFailed(error)
        }
    }
}

// MARK: - Errors

extension PoisRequestService {
    enum ServiceError: LocalizedError {
        case invalidURL
        case invalidResponse
        case httpStatus(Int)
        case decodingFailed(Error)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid server URL"
            case .invalidResponse:
                return "Server returned an unexpected response"
            case .httpStatus(let code):
                return "Server returned status \(code)"
            case .decodingFailed(let error):
                return "Failed to parse server response: \(error.localizedDescription)"
            }
        }
    }
}
