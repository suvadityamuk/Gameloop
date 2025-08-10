//
//  GameCreationService.swift
//  Gameloop
//
//  Created by Suvaditya Mukherjee on 8/9/25.
//

import Foundation
import Combine

// MARK: - Game Creation Service
final class GameCreationService: ObservableObject {
    static let shared = GameCreationService()
    
    @Published var isCreating = false
    @Published var creationProgress: String = ""
    
    private init() {}
    
    // MARK: - Game Creation Pipeline
    func createGame(from description: String) async throws -> Game {
        await MainActor.run {
            isCreating = true
            creationProgress = "Analyzing your game idea..."
        }
        
        // Step 1: Select appropriate mini-game based on description
        let (selectedGame, gameCode) = selectMiniGame(from: description)
        
        await MainActor.run {
            creationProgress = "Building your game..."
        }
        
        // Step 2: Create data URL for immediate playback
        let webviewURL = createDataURL(from: gameCode)
        
        await MainActor.run {
            creationProgress = "Finalizing..."
        }
        
        // Step 3: Create Game object
        let game = Game(
            id: Int.random(in: 10000...99999),
            gameName: selectedGame,
            creatorName: "@you",
            webviewURL: webviewURL,
            imageName: nil
        )
        
        await MainActor.run {
            isCreating = false
            creationProgress = ""
        }
        
        return game
    }
    
    // MARK: - Game Creation with Custom Name
    func createGameWithName(from description: String, name: String) async throws -> Game {
        await MainActor.run {
            isCreating = true
            creationProgress = "Analyzing your game idea..."
        }
        
        // Step 1: Select appropriate mini-game based on description
        let (_, gameCode) = selectMiniGame(from: description)
        
        await MainActor.run {
            creationProgress = "Building your game..."
        }
        
        // Step 2: Create data URL for immediate playback
        let webviewURL = createDataURL(from: gameCode)
        
        await MainActor.run {
            creationProgress = "Finalizing..."
        }
        
        // Step 3: Create Game object
        let game = Game(
            id: Int.random(in: 10000...99999),
            gameName: name,
            creatorName: "@you",
            webviewURL: webviewURL,
            imageName: nil
        )
        
        await MainActor.run {
            isCreating = false
            creationProgress = ""
        }
        
        return game
    }
    
    // MARK: - Preview Generation
    func generatePreviewHTML(description: String, name: String) async -> String {
        // Generate a quick preview version of the game
        await MainActor.run {
            creationProgress = "Generating preview..."
        }
        
        // Simulate some delay for preview generation
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let (_, gameCode) = selectMiniGame(from: description)
        return gameCode
    }
    
    // MARK: - Claude Code Integration
    private func generateGameCode(description: String) async throws -> String {
        await MainActor.run {
            creationProgress = "Generating game code with AI..."
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let gamePrompt = generateGamePrompt(from: description)
        
        // TODO: Replace with actual Claude Code API integration
        // For now, return a sample HTML5 game template
        return generateSampleGame(description: description)
    }
    
    private func generateGameCodeWithName(description: String, name: String) async throws -> String {
        await MainActor.run {
            creationProgress = "Generating game code with AI..."
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let gamePrompt = generateGamePromptWithName(from: description, name: name)
        
        // TODO: Replace with actual Claude Code API integration
        // For now, return a sample HTML5 game template
        return generateSampleGameWithName(description: description, name: name)
    }
    
    private func generateGamePrompt(from description: String) -> String {
        return """
        Create a simple, engaging HTML5 browser game based on this description: "\(description)"
        
        Requirements:
        - Single HTML file with embedded CSS and JavaScript
        - Responsive design that works well in portrait mobile webview
        - Touch/click controls optimized for mobile
        - Simple, colorful graphics using Canvas API or CSS
        - Game should be playable immediately without external dependencies
        - Include a score system
        - Modern, attractive visual design
        - Smooth animations and effects
        - Game should be fun and engaging for casual players
        
        Make the game creative and polished. Focus on user experience and visual appeal.
        """
    }
    
    private func generateGamePromptWithName(from description: String, name: String) -> String {
        return """
        Create a simple, engaging HTML5 browser game based on this description: "\(description)"
        Game name: "\(name)"
        
        Requirements:
        - Single HTML file with embedded CSS and JavaScript
        - Responsive design that works well in portrait mobile webview
        - Touch/click controls optimized for mobile
        - Simple, colorful graphics using Canvas API or CSS
        - Game should be playable immediately without external dependencies
        - Include a score system
        - Modern, attractive visual design
        - Smooth animations and effects
        - Game should be fun and engaging for casual players
        - Use the provided game name in the title and UI
        
        Make the game creative and polished. Focus on user experience and visual appeal.
        """
    }
    
    private func generateSampleGame(description: String) -> String {
        let gameName = extractGameName(from: description)
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(gameName)</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    color: white;
                    touch-action: manipulation;
                }
                #gameContainer {
                    width: 100%;
                    max-width: 400px;
                    height: 80vh;
                    background: rgba(0,0,0,0.2);
                    border-radius: 20px;
                    padding: 20px;
                    text-align: center;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                }
                canvas {
                    background: rgba(255,255,255,0.1);
                    border-radius: 15px;
                    margin: 20px 0;
                    cursor: pointer;
                    touch-action: none;
                }
                h1 {
                    font-size: 2em;
                    margin-bottom: 10px;
                    background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                    background-clip: text;
                }
                #score {
                    font-size: 1.5em;
                    font-weight: bold;
                    margin-bottom: 20px;
                }
                button {
                    background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
                    border: none;
                    padding: 15px 30px;
                    border-radius: 25px;
                    color: white;
                    font-size: 1.1em;
                    font-weight: bold;
                    cursor: pointer;
                    margin: 10px;
                    transition: transform 0.2s;
                }
                button:active { transform: scale(0.95); }
            </style>
        </head>
        <body>
            <div id="gameContainer">
                <h1>\(gameName)</h1>
                <div id="score">Score: 0</div>
                <canvas id="gameCanvas" width="300" height="400"></canvas>
                <button onclick="startGame()">Start Game</button>
                <button onclick="resetGame()">Reset</button>
            </div>
            
            <script>
                const canvas = document.getElementById('gameCanvas');
                const ctx = canvas.getContext('2d');
                let score = 0;
                let gameRunning = false;
                
                // Simple game logic based on description
                let player = { x: 150, y: 350, width: 20, height: 20, speed: 5 };
                let obstacles = [];
                
                function startGame() {
                    gameRunning = true;
                    obstacles = [];
                    score = 0;
                    updateScore();
                    gameLoop();
                }
                
                function resetGame() {
                    gameRunning = false;
                    obstacles = [];
                    score = 0;
                    updateScore();
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    drawPlayer();
                }
                
                function updateScore() {
                    document.getElementById('score').textContent = `Score: ${score}`;
                }
                
                function drawPlayer() {
                    ctx.fillStyle = '#ff6b6b';
                    ctx.fillRect(player.x, player.y, player.width, player.height);
                }
                
                function drawObstacles() {
                    ctx.fillStyle = '#4ecdc4';
                    obstacles.forEach(obs => {
                        ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
                    });
                }
                
                function updateGame() {
                    if (!gameRunning) return;
                    
                    // Move obstacles
                    obstacles.forEach(obs => obs.y += 3);
                    obstacles = obstacles.filter(obs => obs.y < canvas.height);
                    
                    // Add new obstacles
                    if (Math.random() < 0.02) {
                        obstacles.push({
                            x: Math.random() * (canvas.width - 20),
                            y: 0,
                            width: 20,
                            height: 20
                        });
                    }
                    
                    // Check collisions
                    obstacles.forEach(obs => {
                        if (player.x < obs.x + obs.width &&
                            player.x + player.width > obs.x &&
                            player.y < obs.y + obs.height &&
                            player.y + player.height > obs.y) {
                            gameRunning = false;
                        }
                    });
                    
                    score += gameRunning ? 1 : 0;
                    updateScore();
                }
                
                function draw() {
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    drawPlayer();
                    drawObstacles();
                }
                
                function gameLoop() {
                    if (!gameRunning) return;
                    
                    updateGame();
                    draw();
                    requestAnimationFrame(gameLoop);
                }
                
                // Touch/mouse controls
                canvas.addEventListener('touchstart', handleTouch);
                canvas.addEventListener('touchmove', handleTouch);
                canvas.addEventListener('mousemove', handleMouse);
                
                function handleTouch(e) {
                    e.preventDefault();
                    const rect = canvas.getBoundingClientRect();
                    const touch = e.touches[0];
                    player.x = (touch.clientX - rect.left) * (canvas.width / rect.width) - player.width/2;
                    player.x = Math.max(0, Math.min(canvas.width - player.width, player.x));
                }
                
                function handleMouse(e) {
                    const rect = canvas.getBoundingClientRect();
                    player.x = (e.clientX - rect.left) * (canvas.width / rect.width) - player.width/2;
                    player.x = Math.max(0, Math.min(canvas.width - player.width, player.x));
                }
                
                // Initial draw
                drawPlayer();
            </script>
        </body>
        </html>
        """
    }
    
    private func generateSampleGameWithName(description: String, name: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(name)</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    color: white;
                    touch-action: manipulation;
                }
                #gameContainer {
                    width: 100%;
                    max-width: 400px;
                    height: 80vh;
                    background: rgba(0,0,0,0.2);
                    border-radius: 20px;
                    padding: 20px;
                    text-align: center;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                }
                canvas {
                    background: rgba(255,255,255,0.1);
                    border-radius: 15px;
                    margin: 20px 0;
                    cursor: pointer;
                    touch-action: none;
                }
                h1 {
                    font-size: 2em;
                    margin-bottom: 10px;
                    background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                    background-clip: text;
                }
                #score {
                    font-size: 1.5em;
                    font-weight: bold;
                    margin-bottom: 20px;
                }
                button {
                    background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
                    border: none;
                    padding: 15px 30px;
                    border-radius: 25px;
                    color: white;
                    font-size: 1.1em;
                    font-weight: bold;
                    cursor: pointer;
                    margin: 10px;
                    transition: transform 0.2s;
                }
                button:active { transform: scale(0.95); }
                .preview-banner {
                    background: rgba(255, 193, 7, 0.2);
                    border: 2px solid rgba(255, 193, 7, 0.5);
                    border-radius: 12px;
                    padding: 8px 12px;
                    margin-bottom: 20px;
                    font-size: 0.9em;
                    font-weight: 600;
                }
            </style>
        </head>
        <body>
            <div id="gameContainer">
                <div class="preview-banner">🎮 Game Preview</div>
                <h1>\(name)</h1>
                <div id="score">Score: 0</div>
                <canvas id="gameCanvas" width="300" height="400"></canvas>
                <button onclick="startGame()">Start Game</button>
                <button onclick="resetGame()">Reset</button>
            </div>
            
            <script>
                const canvas = document.getElementById('gameCanvas');
                const ctx = canvas.getContext('2d');
                let score = 0;
                let gameRunning = false;
                
                // Simple game logic based on description
                let player = { x: 150, y: 350, width: 20, height: 20, speed: 5 };
                let obstacles = [];
                
                function startGame() {
                    gameRunning = true;
                    obstacles = [];
                    score = 0;
                    updateScore();
                    gameLoop();
                }
                
                function resetGame() {
                    gameRunning = false;
                    obstacles = [];
                    score = 0;
                    updateScore();
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    drawPlayer();
                }
                
                function updateScore() {
                    document.getElementById('score').textContent = `Score: ${score}`;
                }
                
                function drawPlayer() {
                    ctx.fillStyle = '#ff6b6b';
                    ctx.fillRect(player.x, player.y, player.width, player.height);
                }
                
                function drawObstacles() {
                    ctx.fillStyle = '#4ecdc4';
                    obstacles.forEach(obs => {
                        ctx.fillRect(obs.x, obs.y, obs.width, obs.height);
                    });
                }
                
                function updateGame() {
                    if (!gameRunning) return;
                    
                    // Move obstacles
                    obstacles.forEach(obs => obs.y += 3);
                    obstacles = obstacles.filter(obs => obs.y < canvas.height);
                    
                    // Add new obstacles
                    if (Math.random() < 0.02) {
                        obstacles.push({
                            x: Math.random() * (canvas.width - 20),
                            y: 0,
                            width: 20,
                            height: 20
                        });
                    }
                    
                    // Check collisions
                    obstacles.forEach(obs => {
                        if (player.x < obs.x + obs.width &&
                            player.x + player.width > obs.x &&
                            player.y < obs.y + obs.height &&
                            player.y + player.height > obs.y) {
                            gameRunning = false;
                        }
                    });
                    
                    score += gameRunning ? 1 : 0;
                    updateScore();
                }
                
                function draw() {
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    drawPlayer();
                    drawObstacles();
                }
                
                function gameLoop() {
                    if (!gameRunning) return;
                    
                    updateGame();
                    draw();
                    requestAnimationFrame(gameLoop);
                }
                
                // Touch/mouse controls
                canvas.addEventListener('touchstart', handleTouch);
                canvas.addEventListener('touchmove', handleTouch);
                canvas.addEventListener('mousemove', handleMouse);
                
                function handleTouch(e) {
                    e.preventDefault();
                    const rect = canvas.getBoundingClientRect();
                    const touch = e.touches[0];
                    player.x = (touch.clientX - rect.left) * (canvas.width / rect.width) - player.width/2;
                    player.x = Math.max(0, Math.min(canvas.width - player.width, player.x));
                }
                
                function handleMouse(e) {
                    const rect = canvas.getBoundingClientRect();
                    player.x = (e.clientX - rect.left) * (canvas.width / rect.width) - player.width/2;
                    player.x = Math.max(0, Math.min(canvas.width - player.width, player.x));
                }
                
                // Initial draw
                drawPlayer();
            </script>
        </body>
        </html>
        """
    }
    
    // MARK: - Freestyle.sh Integration
    private func deployToFreestyle(gameCode: String, gameName: String) async throws -> String {
        let freestyleService = FreestyleService.shared
        
        // Set up progress tracking
        var progressCancellable: AnyCancellable?
        
        progressCancellable = freestyleService.$deploymentProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                guard let self = self else { return }
                if !progress.isEmpty {
                    self.creationProgress = progress
                }
            }
        
        defer {
            progressCancellable?.cancel()
        }
        
        do {
            // Use real deployment with API key
            let deploymentURL = try await freestyleService.deployHTML(
                html: gameCode,
                name: gameName,
                description: "AI-generated game created with Gameloop"
            )
            
            return deploymentURL
        } catch {
            // Fallback to mock URL if deployment fails
            print("Freestyle deployment failed: \(error), using mock URL as fallback")
            
            await MainActor.run {
                self.creationProgress = "Deployment failed, using fallback..."
            }
            
            return try await freestyleService.mockDeploy(html: gameCode, name: gameName)
        }
    }
    
    // MARK: - Mini Game Selection
    private func selectMiniGame(from description: String) -> (String, String) {
        let lowercased = description.lowercased()
        
        // Smart game selection based on keywords
        if lowercased.contains("word") || lowercased.contains("letter") || lowercased.contains("guess") {
            return ("Wordle", MiniGames.wordleGame)
        } else if lowercased.contains("2048") || lowercased.contains("tile") || lowercased.contains("merge") || lowercased.contains("number") {
            return ("2048 Mobile", MiniGames.game2048)
        } else if lowercased.contains("snake") || lowercased.contains("food") || lowercased.contains("grow") {
            return ("Snake Classic", MiniGames.snakeGame)
        } else if lowercased.contains("tetris") || lowercased.contains("block") || lowercased.contains("falling") || lowercased.contains("line") {
            return ("Tetris Mini", MiniGames.tetrisGame)
        } else if lowercased.contains("space") || lowercased.contains("3d") || lowercased.contains("ship") || lowercased.contains("asteroid") {
            return ("Space Explorer 3D", MiniGames.threeJSSpaceGame)
        } else {
            // Default to a random game for demo purposes
            let games = MiniGames.getAllMiniGames()
            let randomGame = games.randomElement()!
            return (randomGame.0, randomGame.1)
        }
    }
    
    private func createDataURL(from htmlContent: String) -> String {
        let encodedHTML = htmlContent.data(using: .utf8)?.base64EncodedString() ?? ""
        return "data:text/html;base64,\(encodedHTML)"
    }
    
    // MARK: - Helper Functions
    private func extractGameName(from description: String) -> String {
        // Simple extraction - could be enhanced with AI
        let words = description.split(separator: " ")
        if words.count >= 2 {
            return String(words.prefix(2).joined(separator: " ")).capitalized
        }
        return "My Game"
    }
}

// MARK: - API Models
struct ClaudeCodeRequest: Codable {
    let prompt: String
    let maxTokens: Int
    let model: String
}

struct ClaudeCodeResponse: Codable {
    let completion: String
    let stopReason: String?
}