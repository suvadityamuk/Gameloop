import SwiftUI
import Combine

// --- Data Models
struct Game: Identifiable, Hashable {
    let id: Int
    let gameName: String
    let creatorName: String
    let webviewURL: String? // URL to the deployed game
    let imageName: String? // nil -> gradient fallback
}

struct User: Identifiable {
    let id: Int
    let username: String
    let profileImageName: String?
    let followersCount: Int
    let followingCount: Int
    let subscribersCount: Int
    let createdGames: [Game]
}

// ViewModels removed - using shared GameManager instead

// --- Main App Container
struct ContentView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var gameManager = GameManager.shared
    private let tabBarHeight: CGFloat = 62

    var body: some View {
        ZStack {
            // Tab content
            switch navigationCoordinator.selectedTab {
            case .home:
                HomeView(overlayGapAboveBar: 40)
                    .environmentObject(gameManager)
                    .environmentObject(navigationCoordinator)
            case .studio:
                StudioView()
                    .environmentObject(gameManager)
                    .environmentObject(navigationCoordinator)
            case .explore:
                ExploreView()
                    .environmentObject(gameManager)
                    .environmentObject(navigationCoordinator)
            case .profile:
                ProfileView()
                    .environmentObject(gameManager)
                    .environmentObject(navigationCoordinator)
            }
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selected: $navigationCoordinator.selectedTab, height: tabBarHeight)
                .ignoresSafeArea(edges: .bottom)
        }
        .background(.black)
        .sheet(item: $navigationCoordinator.gameToPlay) { game in
            FullScreenGameView(game: game)
        }
    }
}

// --- Full Screen Game View
struct FullScreenGameView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let webviewURL = game.webviewURL {
                    GameWebView(url: webviewURL)
                        .ignoresSafeArea(edges: .bottom)
                        .onDisappear {
                            // WebView cleanup handled by system
                        }
                } else {
                    VStack(spacing: 20) {
                        Text("🎮")
                            .font(.system(size: 60))
                        
                        Text(game.gameName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("by \(game.creatorName)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Game is being prepared...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Share functionality
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// --- Home Feed View
struct HomeView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var pageIndex = 0
    @State private var displayedGames: [Game] = []
    let overlayGapAboveBar: CGFloat

    var body: some View {
        VerticalPager(
            pages: displayedGames.map { game in
                GamePage(game: game, overlayGapAboveBar: overlayGapAboveBar + 62) { selectedGame in
                    navigationCoordinator.playGame(selectedGame)
                }
            },
            index: $pageIndex,
            onIndexNearEnd: {
                loadMoreGames()
            }
        )
        .ignoresSafeArea()
        .onAppear {
            if displayedGames.isEmpty {
                loadMoreGames()
            }
        }
        .onReceive(gameManager.$allGames) { _ in
            // Refresh feed when new games are added
            loadMoreGames()
        }
    }
    
    private func loadMoreGames() {
        let newGames = gameManager.getRandomGames(count: 5)
        displayedGames.append(contentsOf: newGames)
        
        // Limit total displayed games to prevent memory issues
        if displayedGames.count > 30 {
            displayedGames.removeFirst(10) // Remove older games
        }
    }
}

// --- Game Page
private struct GamePage: View {
    let game: Game
    let overlayGapAboveBar: CGFloat
    let onGameTap: (Game) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Always use fallback background in feed to prevent WebView memory issues
            // WebView will only be used in full-screen mode
            FeedBackground(imageName: game.imageName)
            
            // Tap overlay for full screen
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    onGameTap(game)
                }

            // Bottom overlay content
            HStack(alignment: .bottom) {
                InfoCard(title: game.gameName, subtitle: game.creatorName)
                    .padding(.leading, 16)
                    .onTapGesture {
                        onGameTap(game)
                    }
                
                Spacer()
                
                VStack(spacing: 12) {
                    PlayButton {
                        onGameTap(game)
                    }
                    
                    ShareButton()
                }
                .padding(.trailing, 16)
            }
            .padding(.bottom, overlayGapAboveBar)
        }
    }
}

// --- Play Button
private struct PlayButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "play.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 56, height: 56)
                .background(
                    Circle().fill(LinearGradient(colors: [Brand.lemon, Brand.sky], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
                )
        }
    }
}

// --- Visual pieces (unchanged)
private struct FeedBackground: View {
    var imageName: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            if let name = imageName, UIImage(named: name) != nil {
                Image(name).resizable().scaledToFill()
            } else {
                LinearGradient(stops: [
                    .init(color: Brand.sky,   location: 0.0),
                    .init(color: Brand.blush, location: 0.55),
                    .init(color: Brand.lemon, location: 1.0),
                ], startPoint: .top, endPoint: .bottom)
            }
            LinearGradient(colors: [.clear, .black.opacity(0.65)],
                           startPoint: .center, endPoint: .bottom)
                .frame(height: 240)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

private struct InfoCard: View {
    var title: String
    var subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
            Text(subtitle).font(.system(size: 13)).foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 0.5))
    }
}

private struct ShareButton: View {
    var body: some View {
        Button { } label: {
            Image(systemName: "square.and.arrow.up.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle().fill(.ultraThinMaterial)
                        .overlay(
                            Circle().stroke(
                                LinearGradient(colors: [Brand.lemon, Brand.blush, Brand.sky],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
        }
    }
}

// Tab enum moved to GameManager.swift

private struct CustomTabBar: View {
    @Binding var selected: Tab
    var height: CGFloat

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea(edges: .bottom)
            Rectangle().fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
                .frame(maxHeight: .infinity, alignment: .top)

            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button { selected = tab } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                if selected == tab {
                                    Circle()
                                        .fill(LinearGradient(colors: [Brand.sky, Brand.lemon],
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 36, height: 36)
                                        .shadow(color: .black.opacity(0.25), radius: 6, y: 4)
                                }
                                Image(systemName: tab.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(selected == tab ? .black : .white.opacity(0.92))
                            }
                            Text(tab.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(selected == tab ? 0.95 : 0.75))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.bottom, 6)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: height + 16)
    }
}

// --- Creator Studio View
struct StudioView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @StateObject private var studioVM = StudioViewModel()
    @State private var gameDescription = ""
    @State private var gameName = ""
    @State private var showingNameInput = false
    @State private var showingCreationFlow = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [Brand.sky, Brand.blush], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Creator Studio")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Describe your game idea and we'll build it for you")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 40)
                        
                        // Game Description Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What's your game idea?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                TextEditor(text: $gameDescription)
                                    .font(.system(size: 16))
                                    .padding(16)
                                    .background(Color.white.opacity(0.1))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 120)
                                
                                // Character count
                                HStack {
                                    Spacer()
                                    Text("\(gameDescription.count)/500")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                }
                                .background(Color.white.opacity(0.05))
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Examples
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Need inspiration?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(studioVM.gameExamples, id: \.self) { example in
                                        Button {
                                            gameDescription = example
                                        } label: {
                                            Text(example)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                        .fill(.ultraThinMaterial)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                                        )
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Create Game Button
                VStack {
                    Spacer()
                    
                    Button {
                        if !gameDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showingNameInput = true
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if studioVM.isCreatingGame {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Text(studioVM.isCreatingGame ? "Creating Game..." : "Next: Name Your Game")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .foregroundColor(
                            gameDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                ? .white.opacity(0.6) 
                                : .black
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: gameDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                    ? [.white.opacity(0.3), .white.opacity(0.2)] 
                                    : [Brand.lemon, Brand.sky],
                                startPoint: .leading, 
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(
                            color: gameDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                ? .clear 
                                : .black.opacity(0.2), 
                            radius: 10, y: 5
                        )
                    }
                    .disabled(gameDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || studioVM.isCreatingGame)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingNameInput) {
            GameNameInputSheet(
                gameDescription: gameDescription,
                gameName: $gameName,
                onContinue: {
                    showingNameInput = false
                    showingCreationFlow = true
                }
            )
        }
        .sheet(isPresented: $showingCreationFlow) {
            GameCreationFlow(
                gameDescription: gameDescription,
                gameName: gameName,
                studioVM: studioVM,
                gameManager: gameManager,
                navigationCoordinator: navigationCoordinator
            )
        }
    }
}

// --- Game Name Input Sheet
struct GameNameInputSheet: View {
    let gameDescription: String
    @Binding var gameName: String
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var localGameName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Brand.blush, Brand.lemon], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Name Your Game")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("What should we call this amazing creation?")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Game Description Reminder
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Game Idea:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(gameDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Game Name Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Game Name")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            TextField("Enter a catchy name...", text: $localGameName)
                                .font(.system(size: 18, weight: .medium))
                                .padding(16)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Character count
                            HStack {
                                Spacer()
                                Text("\(localGameName.count)/30")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                            }
                            .background(Color.white.opacity(0.05))
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Continue Button
                    Button {
                        gameName = localGameName.trimmingCharacters(in: .whitespacesAndNewlines)
                        onContinue()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Continue to Preview")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(
                            localGameName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                ? .white.opacity(0.6) 
                                : .black
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: localGameName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                    ? [.white.opacity(0.3), .white.opacity(0.2)] 
                                    : [.white, .white.opacity(0.9)],
                                startPoint: .leading, 
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(
                            color: localGameName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                ? .clear 
                                : .black.opacity(0.2), 
                            radius: 10, y: 5
                        )
                    }
                    .disabled(localGameName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            localGameName = gameName
        }
    }
}

// --- Studio View Model
final class StudioViewModel: ObservableObject {
    @Published var isCreatingGame = false
    @Published var createdGames: [Game] = []
    @Published var creationProgress = ""
    
    private let gameCreationService = GameCreationService.shared
    
    let gameExamples = [
        "A space adventure where you dodge asteroids",
        "A puzzle game with colorful blocks",
        "A racing game through neon cities",
        "A platformer in a magical forest",
        "A rhythm game with dancing animals"
    ]
    
    init() {
        // Observe the service for progress updates
        gameCreationService.$isCreating
            .receive(on: DispatchQueue.main)
            .assign(to: &$isCreatingGame)
        
        gameCreationService.$creationProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$creationProgress)
    }
    
    func createGame(description: String) async -> Game? {
        do {
            let newGame = try await gameCreationService.createGame(from: description)
            
            await MainActor.run {
                createdGames.append(newGame)
            }
            
            return newGame
        } catch {
            await MainActor.run {
                print("Failed to create game: \(error)")
            }
            return nil
        }
    }
    
    func createGameWithName(description: String, name: String) async -> Game? {
        do {
            let newGame = try await gameCreationService.createGameWithName(from: description, name: name)
            
            await MainActor.run {
                createdGames.append(newGame)
            }
            
            return newGame
        } catch {
            await MainActor.run {
                print("Failed to create game: \(error)")
            }
            return nil
        }
    }
    
    func generatePreviewHTML(description: String, name: String) async -> String {
        return await gameCreationService.generatePreviewHTML(description: description, name: name)
    }
}

// --- Game Creation Flow
struct GameCreationFlow: View {
    let gameDescription: String
    let gameName: String
    @ObservedObject var studioVM: StudioViewModel
    @ObservedObject var gameManager: GameManager
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var showingSuccess = false
    @State private var createdGame: Game?
    @State private var showingPreview = false
    @State private var gamePreviewHTML = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Brand.blush, Brand.lemon], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text(showingPreview ? "Game Preview" : (studioVM.isCreatingGame ? "Creating Your Game" : "Game Created!"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .animation(.easeInOut, value: studioVM.isCreatingGame)
                    
                    if !showingPreview {
                        VStack(spacing: 8) {
                            Text("\"\(gameName)\"")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(gameDescription)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    if showingPreview {
                        // Game Preview Section
                        VStack(spacing: 20) {
                            Text("Take a look at your game before we deploy it!")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Preview WebView Container
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .frame(height: 300)
                                .overlay(
                                    Group {
                                        if !gamePreviewHTML.isEmpty {
                                            GamePreviewWebView(html: gamePreviewHTML)
                                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        } else {
                                            VStack(spacing: 16) {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(1.2)
                                                
                                                Text("Loading preview...")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                        }
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 16) {
                                // Back to Edit Button
                                Button("Edit Name") {
                                    showingPreview = false
                                    dismiss()
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                
                                // Deploy Button
                                Button("Deploy Game!") {
                                    showingPreview = false
                                    // Start actual creation process
                                    Task {
                                        let newGame = await studioVM.createGameWithName(description: gameDescription, name: gameName)
                                        
                                        await MainActor.run {
                                            if let game = newGame {
                                                gameManager.addCreatedGame(game)
                                                createdGame = game
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    showingSuccess = true
                                                }
                                            }
                                        }
                                    }
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(colors: [.white, .white.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                            }
                            .padding(.horizontal, 20)
                        }
                    } else if studioVM.isCreatingGame {
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text(studioVM.creationProgress.isEmpty ? "Starting..." : studioVM.creationProgress)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .animation(.easeInOut, value: studioVM.creationProgress)
                            
                            Text("This usually takes 2-3 minutes")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .scaleEffect(showingSuccess ? 1.2 : 1.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showingSuccess)
                            
                            Text("Your game is ready to play!")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Button("Play Now") {
                                if let game = createdGame {
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        navigationCoordinator.switchToHome()
                                        navigationCoordinator.playGame(game)
                                    }
                                }
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 200, height: 50)
                            .background(
                                LinearGradient(colors: [.white, .white.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(studioVM.isCreatingGame ? "Cancel" : "Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .task {
            // Generate preview HTML immediately when view appears
            showingPreview = true
            
            // Generate preview content
            let previewHTML = await studioVM.generatePreviewHTML(description: gameDescription, name: gameName)
            
            await MainActor.run {
                gamePreviewHTML = previewHTML
            }
        }
        .onDisappear {
            // Reset state when dismissed
            showingSuccess = false
        }
    }
}

struct ExploreView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedGame: Game?
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                    VStack(spacing: 0) {
                        // Header with Search
                        VStack(spacing: 16) {
                            // Title
                            HStack {
                                Text("Explore")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button {
                                    // Search or filter action
                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            
                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 16))
                                
                                TextField("Search games...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        // Categories
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    Button {
                                        selectedCategory = category
                                    } label: {
                                        Text(category)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(
                                                selectedCategory == category ? .black : .white
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                    .fill(
                                                        selectedCategory == category
                                                        ? LinearGradient(colors: [Brand.lemon, Brand.sky], startPoint: .leading, endPoint: .trailing)
                                                        : LinearGradient(colors: [.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                            .stroke(
                                                                selectedCategory == category
                                                                ? .clear
                                                                : .white.opacity(0.2),
                                                                lineWidth: 1
                                                            )
                                                    )
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)
                        
                        // Games Grid
                        LazyVGrid(columns: columns, spacing: 4) {
                            ForEach(filteredGames) { game in
                                ExploreGameCard(game: game) {
                                    navigationCoordinator.playGame(game)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100) // Space for tab bar
                    }
                }
                .refreshable {
                    // Games automatically refresh from GameManager
                }
            }
        }
    
    // MARK: - Helper Properties
    private let categories = ["All", "Action", "Puzzle", "Racing", "Adventure", "Arcade"]
    
    private var filteredGames: [Game] {
        var games = gameManager.allGames
        
        if !searchText.isEmpty {
            games = games.filter { game in
                game.gameName.localizedCaseInsensitiveContains(searchText) ||
                game.creatorName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Simple category filtering - in a real app, games would have category tags
        // For now, we'll just return all games regardless of category
        return games
    }
}

// ExploreViewModel removed - using shared GameManager

// --- Explore Game Card
struct ExploreGameCard: View {
    let game: Game
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background
                if let webviewURL = game.webviewURL {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Image(systemName: "globe")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        )
                } else if let imageName = game.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else {
                    // Dynamic gradient based on game name hash
                    LinearGradient(stops: [
                        .init(color: Brand.sky, location: 0.0),
                        .init(color: Brand.blush, location: 0.5),
                        .init(color: Brand.lemon, location: 1.0),
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
                
                // Game info overlay
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.gameName)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(game.creatorName)
                            .font(.system(size: 8, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .aspectRatio(3/4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedGame: Game?
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    
    // Mock user data - in real app this would come from auth/user service
    private var currentUser: User {
        User(
            id: 1,
            username: "@you",
            profileImageName: nil,
            followersCount: 1250,
            followingCount: 345,
            subscribersCount: 890,
            createdGames: gameManager.userCreatedGames
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [Brand.lemon, Brand.sky], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Header
                        VStack(spacing: 20) {
                            // Profile Image
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle().stroke(
                                            LinearGradient(
                                                colors: [Brand.lemon, Brand.blush, Brand.sky],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                    )
                                
                                if let imageName = currentUser.profileImageName {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 90)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            // Username
                            Text(currentUser.username)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Stats
                            HStack(spacing: 40) {
                                VStack(spacing: 4) {
                                    Text("\(currentUser.createdGames.count)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Games")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                VStack(spacing: 4) {
                                    Text("\(currentUser.followersCount)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Followers")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                VStack(spacing: 4) {
                                    Text("\(currentUser.followingCount)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Following")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                VStack(spacing: 4) {
                                    Text("\(currentUser.subscribersCount)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Subscribers")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 30)
                        
                        // Games Grid Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("My Games")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(currentUser.createdGames.count) games")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 20)
                            
                            if currentUser.createdGames.isEmpty {
                                // Empty State
                                VStack(spacing: 16) {
                                    Image(systemName: "gamecontroller")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.4))
                                    
                                    Text("No games yet")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("Visit the Studio to create your first game")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 50)
                            } else {
                                // Games Grid
                                LazyVGrid(columns: columns, spacing: 8) {
                                    ForEach(currentUser.createdGames) { game in
                                        GameGridCard(game: game) {
                                            navigationCoordinator.playGame(game)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 100) // Space for tab bar
                    }
                }
            }
        }
    }
}

// --- Game Grid Card
struct GameGridCard: View {
    let game: Game
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background
                if let webviewURL = game.webviewURL {
                    // Show a mini preview or placeholder for webview games
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.8))
                        )
                } else if let imageName = game.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else {
                    LinearGradient(stops: [
                        .init(color: Brand.sky, location: 0.0),
                        .init(color: Brand.blush, location: 0.55),
                        .init(color: Brand.lemon, location: 1.0),
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
                
                // Game Title Overlay
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(game.gameName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .aspectRatio(3/4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// GameDetailSheet removed - using FullScreenGameView instead

// --- Game WebView Component
import WebKit

struct GameWebView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.suppressesIncrementalRendering = false
        
        // Memory optimization settings
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = true
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Handle data URLs properly
        if url.hasPrefix("data:text/html;base64,") {
            // For data URLs, decode and load as HTML string
            let base64String = String(url.dropFirst(22)) // Remove "data:text/html;base64,"
            if let data = Data(base64Encoded: base64String),
               let htmlString = String(data: data, encoding: .utf8) {
                print("✅ Loading HTML game, size: \(htmlString.count) characters")
                webView.loadHTMLString(htmlString, baseURL: nil)
            } else {
                print("❌ Failed to decode data URL of length: \(url.count)")
            }
        } else {
            // For regular URLs
            if let urlObj = URL(string: url), webView.url != urlObj {
                print("✅ Loading URL: \(url)")
                webView.load(URLRequest(url: urlObj))
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed to load: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Error code: \(nsError.code), domain: \(nsError.domain)")
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView navigation failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView finished loading successfully")
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("📱 WebView started loading...")
        }
    }
}

// --- Game Preview WebView
struct GamePreviewWebView: UIViewRepresentable {
    let html: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.suppressesIncrementalRendering = false
        
        // Memory optimization settings
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = true
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only reload if HTML content has changed
        if webView.url?.absoluteString != "about:blank" || !html.isEmpty {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Preview WebView failed to load: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Preview WebView navigation failed: \(error.localizedDescription)")
        }
    }
}

#Preview("iPhone 16 Pro") { ContentView() }
