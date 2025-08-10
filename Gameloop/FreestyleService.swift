//
//  FreestyleService.swift
//  Gameloop
//
//  Created by Suvaditya Mukherjee on 8/9/25.
//

import Foundation

// MARK: - Freestyle.sh Service
final class FreestyleService: ObservableObject {
    static let shared = FreestyleService()
    
    @Published var deploymentProgress = ""
    @Published var isDeploying = false
    
    private let session = URLSession.shared
    private let apiKey = "Eda8FRTACJeDF1WhJ6nLWc-FrS7wBjEP8tw24morCpe9T9XTgRqzQaoyZGouuniwttL"
    
    private init() {}
    
    // MARK: - Web Deployment
    func deployHTML(html: String, name: String, description: String? = nil) async throws -> String {
        await MainActor.run {
            isDeploying = true
            deploymentProgress = "Preparing deployment..."
        }
        
        // Create deployment request using the correct Freestyle API format
        let deploymentRequest = FreestyleWebDeployRequest(
            source: .files([
                "index.html": FileContent(content: html, encoding: "utf-8"),
                "package.json": FileContent(
                    content: """
                    {
                      "name": "\(name.lowercased().replacingOccurrences(of: " ", with: "-"))",
                      "version": "1.0.0",
                      "description": "\(description ?? "HTML5 Game created with Gameloop")",
                      "main": "server.js",
                      "scripts": {
                        "start": "node server.js"
                      },
                      "dependencies": {
                        "express": "^4.18.2"
                      }
                    }
                    """,
                    encoding: "utf-8"
                ),
                "server.js": FileContent(
                    content: """
                    const express = require('express');
                    const path = require('path');
                    const app = express();
                    
                    app.use(express.static('.'));
                    
                    app.get('/', (req, res) => {
                        res.sendFile(path.join(__dirname, 'index.html'));
                    });
                    
                    const port = process.env.PORT || 3000;
                    app.listen(port, () => {
                        console.log(`Server running on port ${port}`);
                    });
                    """,
                    encoding: "utf-8"
                )
            ]),
            config: FreestyleWebDeployConfig(
                domains: [generateRandomDomain(name: name)],
                build: true,
                entrypoint: "server.js",
                envVars: [:],
                timeout: 60
            )
        )
        
        await MainActor.run {
            deploymentProgress = "Uploading files to Freestyle..."
        }
        
        let deployment = try await performDeployment(request: deploymentRequest)
        
        await MainActor.run {
            deploymentProgress = "Deployment created, monitoring status..."
        }
        
        // Monitor deployment progress
        let finalURL = try await monitorDeployment(deploymentId: deployment.deploymentId)
        
        await MainActor.run {
            isDeploying = false
            deploymentProgress = "Deployment completed!"
        }
        
        return finalURL
    }
    
    // MARK: - Private Methods
    private func performDeployment(request: FreestyleWebDeployRequest) async throws -> FreestyleDeploymentResponse {
        guard let url = URL(string: "https://api.freestyle.sh/web/v1/deployment") else {
            throw FreestyleError.invalidURL
        }
        
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        httpRequest.timeoutInterval = 60
        
        let jsonData = try JSONEncoder().encode(request)
        httpRequest.httpBody = jsonData
        
//        print(httpRequest.httpBody)
//        print(jsonData)
//        if let jsonString = String(data: jsonData, encoding: .utf8) {
//            print(jsonString)
//        } else {
//            print("Failed to convert data to a UTF-8 string.")
//        }
//        print(request)
        
        let (data, response) = try await session.data(for: httpRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FreestyleError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
            // Try to get error message from response
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String {
                throw FreestyleError.apiError(message: message, statusCode: httpResponse.statusCode)
            } else {
                throw FreestyleError.deploymentFailed(statusCode: httpResponse.statusCode)
            }
        }
        
//        print(httpResponse)
        if let contentString = String(data: data, encoding: .utf8) {
                print("✅ Response Content:\n\(contentString)")
            } else {
                print("❌ Could not convert data to string.")
            }
        let deploymentResponse = try JSONDecoder().decode(FreestyleDeploymentResponse.self, from: data)
        return deploymentResponse
    }
    
    private func monitorDeployment(deploymentId: String) async throws -> String {
        let maxAttempts = 60 // 5 minutes with 5-second intervals
        
        for attempt in 1...maxAttempts {
            await MainActor.run {
                deploymentProgress = "Building deployment... (\(attempt)/\(maxAttempts))"
            }
            
            do {
                let status = try await getDeploymentStatus(deploymentId: deploymentId)
                
                if let domains = status.domains, !domains.isEmpty {
                    return "https://\(domains[0])"
                } else if status.status == "failed" {
                    throw FreestyleError.buildFailed
                } else if status.status == "ready" {
                    // Should have domains by now, but fallback
                    return "https://\(deploymentId).freestyle.sh"
                }
                
                await MainActor.run {
                    deploymentProgress = "Status: \(status.status)"
                }
                
            } catch {
                print("Error checking deployment status: \(error)")
            }
            
            // Wait 5 seconds before next check
            try await Task.sleep(nanoseconds: 5_000_000_000)
        }
        
        throw FreestyleError.deploymentTimeout
    }
    
    private func getDeploymentStatus(deploymentId: String) async throws -> DeploymentStatus {
        guard let url = URL(string: "https://api.freestyle.sh/web/v1/\(deploymentId)") else {
            throw FreestyleError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FreestyleError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw FreestyleError.deploymentNotFound
        }
        
        let status = try JSONDecoder().decode(DeploymentStatus.self, from: data)
        return status
    }
    
    private func generateRandomDomain(name: String) -> String {
        let gameSlug = name.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)
            .prefix(20) // Limit length
        
        let randomSuffix = String(format: "%04d", Int.random(in: 1000...9999))
        return "\(gameSlug)-\(randomSuffix).style.dev"
    }
    
    // MARK: - Mock Deployment (fallback)
    func mockDeploy(html: String, name: String) async throws -> String {
        await MainActor.run {
            isDeploying = true
            deploymentProgress = "Mock deployment starting..."
        }
        
        // Simulate realistic deployment steps
        let steps = [
            "Preparing deployment...",
            "Uploading files...",
            "Installing dependencies...",
            "Building application...",
            "Starting server...",
            "Deployment complete!"
        ]
        
        for (index, step) in steps.enumerated() {
            await MainActor.run {
                deploymentProgress = step
            }
            try await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
        }
        
        await MainActor.run {
            isDeploying = false
        }
        
        return generateRandomDomain(name: name).replacingOccurrences(of: ".style.dev", with: ".mock.dev")
    }
}

// MARK: - Models

struct FreestyleWebDeployRequest: Codable {
    let source: DeploymentSource
    let config: FreestyleWebDeployConfig
}

enum DeploymentSource: Codable {
    case files([String: FileContent])
    case git(GitSource)
    case tar(String) // URL to tarball
    
    enum CodingKeys: String, CodingKey {
        case kind, files, url, branch, dir
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .files(let files):
            try container.encode("files", forKey: .kind)
            try container.encode(files, forKey: .files)
        case .git(let gitSource):
            try container.encode("git", forKey: .kind)
            try container.encode(gitSource.url, forKey: .url)
            if let branch = gitSource.branch {
                try container.encode(branch, forKey: .branch)
            }
            if let dir = gitSource.dir {
                try container.encode(dir, forKey: .dir)
            }
        case .tar(let url):
            try container.encode("tar", forKey: .kind)
            try container.encode(url, forKey: .url)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        
        switch kind {
        case "files":
            let files = try container.decode([String: FileContent].self, forKey: .files)
            self = .files(files)
        case "git":
            let url = try container.decode(String.self, forKey: .url)
            let branch = try container.decodeIfPresent(String.self, forKey: .branch)
            let dir = try container.decodeIfPresent(String.self, forKey: .dir)
            self = .git(GitSource(url: url, branch: branch, dir: dir))
        case "tar":
            let url = try container.decode(String.self, forKey: .url)
            self = .tar(url)
        default:
            throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: "Unknown source kind: \(kind)")
        }
    }
}

struct GitSource {
    let url: String
    let branch: String?
    let dir: String?
}

struct FileContent: Codable {
    let content: String
    let encoding: String // "utf-8" or "base64"
}

struct FreestyleWebDeployConfig: Codable {
    let domains: [String]
    let build: Bool
    let entrypoint: String?
    let envVars: [String: String]
    let timeout: Int?
    
    enum CodingKeys: String, CodingKey {
        case domains, build, entrypoint, timeout
        case envVars = "envVars"
    }
}

struct FreestyleDeploymentResponse: Codable {
    let deploymentId: String
    let domains: [String]?
    let entrypoint: String?
    
    enum CodingKeys: String, CodingKey {
        case deploymentId, domains, entrypoint
    }
}

struct DeploymentStatus: Codable {
    let id: String
    let status: String
    let domains: [String]?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, domains
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
    
    var isReady: Bool {
        status == "ready"
    }
    
    var isBuilding: Bool {
        status == "building" || status == "pending"
    }
    
    var isFailed: Bool {
        status == "failed" || status == "error"
    }
}

// MARK: - Errors
enum FreestyleError: LocalizedError {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case invalidResponseFormat
    case deploymentFailed(statusCode: Int)
    case deploymentNotFound
    case deploymentTimeout
    case buildFailed
    case networkError(Error)
    case apiError(message: String, statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidRequest:
            return "Invalid deployment request"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidResponseFormat:
            return "Unable to parse response"
        case .deploymentFailed(let statusCode):
            return "Deployment failed with status code: \(statusCode)"
        case .deploymentNotFound:
            return "Deployment not found"
        case .deploymentTimeout:
            return "Deployment timed out"
        case .buildFailed:
            return "Deployment build failed"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let message, let statusCode):
            return "API error (\(statusCode)): \(message)"
        }
    }
}
