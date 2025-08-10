//
//  GameManager.swift
//  Gameloop
//
//  Created by Suvaditya Mukherjee on 8/9/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Tab Enum
enum Tab: String, CaseIterable {
    case home = "Home", studio = "Studio", explore = "Explore", profile = "Profile"
    var icon: String {
        switch self {
        case .home: "house.fill"
        case .studio: "rectangle.stack.fill"
        case .explore: "magnifyingglass"
        case .profile: "person.fill"
        }
    }
}

// MARK: - Shared Game Manager
final class GameManager: ObservableObject {
    static let shared = GameManager()
    
    @Published var allGames: [Game] = []
    @Published var userCreatedGames: [Game] = []
    
    private init() {
        loadInitialGames()
    }
    
    // MARK: - Game Management
    func addCreatedGame(_ game: Game) {
        userCreatedGames.append(game)
        allGames.insert(game, at: 0) // Add to beginning of feed
        cleanupOldGames() // Clean up old games to prevent memory issues
    }
    
    func getRandomGames(count: Int = 5) -> [Game] {
        let availableGames = allGames.shuffled()
        return Array(availableGames.prefix(count))
    }
    
    // MARK: - Memory Management
    private func cleanupOldGames() {
        // Keep only the most recent 50 games to prevent memory issues
        if allGames.count > 50 {
            allGames = Array(allGames.suffix(50))
        }
    }
    
    // MARK: - Initial Data
    private func loadInitialGames() {
        // Load our custom mini-games immediately with data URLs
        loadMiniGamesWithDataURLs()
    }
    
    // MARK: - Load Mini-Games with Data URLs
    private func loadMiniGamesWithDataURLs() {
        // Get all mini-games - MiniGamesExtra contains getAllMiniGames that includes all games
        let allMiniGames = MiniGames.getAllMiniGames()
        
        var gamesToLoad: [Game] = []
        
        // Create games with data URLs for immediate playback
        for (name, html, creator) in allMiniGames {
            let dataURL = createDataURL(from: html)
            let game = Game(
                id: Int.random(in: 10000...99999),
                gameName: name,
                creatorName: creator,
                webviewURL: dataURL,
                imageName: nil
            )
            gamesToLoad.append(game)
        }
        
        // Shuffle the games for variety
        allGames = gamesToLoad.shuffled()
        
        print("✅ Loaded \(allGames.count) mini-games with data URLs for immediate playback")
    }
    
    private func createDataURL(from htmlContent: String) -> String {
        let encodedHTML = htmlContent.data(using: .utf8)?.base64EncodedString() ?? ""
        return "data:text/html;base64,\(encodedHTML)"
    }
}

// MARK: - Navigation Coordinator
final class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var gameToPlay: Game?
    @Published var showingGameDetail = false
    
    func playGame(_ game: Game) {
        gameToPlay = game
        showingGameDetail = true
    }
    
    func switchToHome() {
        selectedTab = .home
    }
}