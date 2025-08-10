# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI iOS application called "Gameloop" - a comprehensive game creation and discovery platform. Features include:

- **TikTok-style vertical feed** for game discovery with WebView integration
- **AI-powered Creator Studio** for generating games from natural language
- **Explore page** with grid-based game discovery and search
- **Profile system** with user stats and created games gallery
- **Real-time game deployment** using freestyle.sh integration

## Development Commands

**Note:** This project requires Xcode for building and testing (command line tools alone are insufficient).

### Building
```bash
# Build the project
xcodebuild -project Gameloop.xcodeproj -scheme Gameloop build

# Clean build
xcodebuild -project Gameloop.xcodeproj -scheme Gameloop clean build
```

### Testing
```bash
# Run all tests
xcodebuild test -project Gameloop.xcodeproj -scheme Gameloop

# Run specific test
xcodebuild test -project Gameloop.xcodeproj -scheme Gameloop -only-testing:GameloopTests/GameloopTests/example
```

**Important:** The project uses Swift Testing framework (not XCTest) - tests use `@Test` attributes and `#expect()` assertions.

## Architecture

### Core Structure
- **GameloopApp.swift**: Main app entry point with standard SwiftUI App structure
- **ContentView.swift**: Main container with tab navigation and individual tab views
- **SmoothVerticalPager.swift**: Custom vertical paging using UIScrollView for smooth transitions
- **VerticalPager.swift**: Legacy paging implementation (replaced by SmoothVerticalPager)
- **Theme.swift**: Brand color system with three main colors (lemon, sky, blush)
- **GameCreationService.swift**: Handles AI game generation and deployment pipeline
- **FreestyleService.swift**: Integration with freestyle.sh for game deployment

### Data Models
- **Game**: Core game model (id, gameName, creatorName, webviewURL, imageName)
- **User**: User profile with stats (followers, following, subscribers, createdGames)

### Tab Architecture
1. **Home**: Vertical feed of games using SmoothVerticalPager with seamless transitions
2. **Studio**: Natural language game creation interface with AI generation
3. **Explore**: Grid-based game discovery with search and categories
4. **Profile**: User stats and created games in responsive grid layout

### Game Creation Pipeline
1. User enters natural language description
2. GameCreationService generates HTML5 game using AI
3. FreestyleService deploys game to freestyle.sh
4. Returns webview URL for in-app game playing

### UI Patterns
- **Glass Morphism Design**: Consistent use of `.ultraThinMaterial` backgrounds
- **WebView Integration**: Portrait-optimized game display in feeds
- **Progressive Enhancement**: Graceful fallbacks from webview to static content
- **Infinite Pagination**: Auto-loading content in Home and Explore feeds

### Visual Components
- **GameWebView**: UIViewRepresentable wrapper for WKWebView
- **GamePage**: Individual game display with overlay controls
- **GameGridCard**: Reusable grid item for Explore and Profile
- **CustomTabBar**: Four-tab navigation with gradient selection indicators

## Game Creation Integration

### Claude Code API Integration
- Located in `GameCreationService.swift`
- Generates HTML5 games from natural language descriptions  
- Currently uses mock implementation - replace with actual API calls
- Includes progress tracking and error handling
- Integrated with Freestyle deployment progress tracking

### Freestyle.sh Integration
- Located in `FreestyleService.swift` - completely rewritten for proper API compliance
- Uses correct Freestyle Web Deploy API endpoints (`/web` instead of `/web/v1/deployment`)
- Implements proper request format with `source` (files) and `config` parameters
- Real-time deployment progress tracking with `@Published` properties
- Automatic domain generation using `.style.dev` domains
- Express.js server wrapper for HTML5 games
- Deployment monitoring with status polling and timeout handling
- Graceful fallback to mock deployment on API failures
- Proper error handling with detailed error messages

### WebView Game Display
- Portrait-optimized responsive games
- Touch controls for mobile interaction
- Integrated within TikTok-style vertical feed
- Fallback to gradient backgrounds when games unavailable

## Project Dependencies

- **SwiftUI**: Primary UI framework
- **WebKit**: For WebView game integration
- **Combine**: For reactive data flow in ViewModels
- **UIKit**: Used by VerticalPager component

No external package dependencies - uses only standard iOS frameworks.