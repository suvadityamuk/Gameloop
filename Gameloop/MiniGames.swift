//
//  MiniGames.swift
//  Gameloop
//
//  Created by Suvaditya Mukherjee on 8/9/25.
//

import Foundation

struct MiniGames {
    
    // MARK: - Wordle Game
    static let wordleGame = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Wordle</title>
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
            .game-container {
                width: 90%;
                max-width: 400px;
                text-align: center;
                padding: 20px;
            }
            h1 {
                font-size: 2.5em;
                margin-bottom: 20px;
                background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            .grid {
                display: grid;
                grid-template-rows: repeat(6, 1fr);
                gap: 8px;
                margin: 20px 0;
                height: 360px;
            }
            .row {
                display: grid;
                grid-template-columns: repeat(5, 1fr);
                gap: 8px;
            }
            .tile {
                border: 2px solid rgba(255,255,255,0.3);
                background: rgba(255,255,255,0.1);
                display: flex;
                justify-content: center;
                align-items: center;
                font-size: 1.8em;
                font-weight: bold;
                color: white;
                border-radius: 8px;
                transition: all 0.3s ease;
            }
            .tile.correct {
                background: #6aaa64;
                border-color: #6aaa64;
                animation: flip 0.6s ease-in-out;
            }
            .tile.present {
                background: #c9b458;
                border-color: #c9b458;
                animation: flip 0.6s ease-in-out;
            }
            .tile.absent {
                background: #787c7e;
                border-color: #787c7e;
                animation: flip 0.6s ease-in-out;
            }
            .keyboard {
                display: grid;
                grid-template-rows: repeat(3, 1fr);
                gap: 8px;
                max-width: 500px;
                margin: 0 auto;
            }
            .keyboard-row {
                display: grid;
                gap: 6px;
            }
            .keyboard-row:first-child {
                grid-template-columns: repeat(10, 1fr);
            }
            .keyboard-row:nth-child(2) {
                grid-template-columns: repeat(9, 1fr);
            }
            .keyboard-row:last-child {
                grid-template-columns: 1.5fr repeat(7, 1fr) 1.5fr;
            }
            .key {
                background: rgba(255,255,255,0.2);
                border: none;
                border-radius: 6px;
                color: white;
                font-weight: bold;
                font-size: 0.9em;
                padding: 12px 6px;
                cursor: pointer;
                transition: background 0.2s;
                touch-action: manipulation;
            }
            .key:hover {
                background: rgba(255,255,255,0.3);
            }
            .key:active {
                transform: scale(0.95);
            }
            .key.wide {
                font-size: 0.7em;
            }
            @keyframes flip {
                0% { transform: rotateX(0deg); }
                50% { transform: rotateX(90deg); }
                100% { transform: rotateX(0deg); }
            }
            .message {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(0,0,0,0.8);
                color: white;
                padding: 20px 40px;
                border-radius: 10px;
                font-size: 1.2em;
                z-index: 1000;
                animation: fadeInOut 2s ease-in-out;
            }
            @keyframes fadeInOut {
                0%, 100% { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
                20%, 80% { opacity: 1; transform: translate(-50%, -50%) scale(1); }
            }
        </style>
    </head>
    <body>
        <div class="game-container">
            <h1>Wordle</h1>
            <div class="grid" id="grid"></div>
            <div class="keyboard">
                <div class="keyboard-row">
                    <button class="key" data-key="Q">Q</button>
                    <button class="key" data-key="W">W</button>
                    <button class="key" data-key="E">E</button>
                    <button class="key" data-key="R">R</button>
                    <button class="key" data-key="T">T</button>
                    <button class="key" data-key="Y">Y</button>
                    <button class="key" data-key="U">U</button>
                    <button class="key" data-key="I">I</button>
                    <button class="key" data-key="O">O</button>
                    <button class="key" data-key="P">P</button>
                </div>
                <div class="keyboard-row">
                    <button class="key" data-key="A">A</button>
                    <button class="key" data-key="S">S</button>
                    <button class="key" data-key="D">D</button>
                    <button class="key" data-key="F">F</button>
                    <button class="key" data-key="G">G</button>
                    <button class="key" data-key="H">H</button>
                    <button class="key" data-key="J">J</button>
                    <button class="key" data-key="K">K</button>
                    <button class="key" data-key="L">L</button>
                </div>
                <div class="keyboard-row">
                    <button class="key wide" data-key="ENTER">ENTER</button>
                    <button class="key" data-key="Z">Z</button>
                    <button class="key" data-key="X">X</button>
                    <button class="key" data-key="C">C</button>
                    <button class="key" data-key="V">V</button>
                    <button class="key" data-key="B">B</button>
                    <button class="key" data-key="N">N</button>
                    <button class="key" data-key="M">M</button>
                    <button class="key wide" data-key="BACKSPACE">⌫</button>
                </div>
            </div>
        </div>
        
        <script>
            const WORDS = ['APPLE', 'BEACH', 'CHAIR', 'DANCE', 'EARTH', 'FLAME', 'GRAPE', 'HOUSE', 'IMAGE', 'JUICE', 'KNIFE', 'LIGHT', 'MUSIC', 'NORTH', 'OCEAN', 'PLANT', 'QUEEN', 'RIVER', 'STONE', 'TIGER', 'UNCLE', 'VALUE', 'WATER', 'YOUNG', 'ZEBRA'];
            const TARGET_WORD = WORDS[Math.floor(Math.random() * WORDS.length)];
            
            let currentRow = 0;
            let currentGuess = [];
            let gameOver = false;
            
            const grid = document.getElementById('grid');
            const keys = document.querySelectorAll('.key');
            
            // Initialize grid
            for (let i = 0; i < 6; i++) {
                const row = document.createElement('div');
                row.className = 'row';
                for (let j = 0; j < 5; j++) {
                    const tile = document.createElement('div');
                    tile.className = 'tile';
                    tile.id = `tile-${i}-${j}`;
                    row.appendChild(tile);
                }
                grid.appendChild(row);
            }
            
            // Handle keyboard input
            keys.forEach(key => {
                key.addEventListener('click', () => handleKeyPress(key.dataset.key));
            });
            
            document.addEventListener('keydown', (e) => {
                const key = e.key.toUpperCase();
                if (key === 'ENTER' || key === 'BACKSPACE' || /^[A-Z]$/.test(key)) {
                    handleKeyPress(key);
                }
            });
            
            function handleKeyPress(key) {
                if (gameOver) return;
                
                if (key === 'ENTER') {
                    if (currentGuess.length === 5) {
                        checkGuess();
                    }
                } else if (key === 'BACKSPACE') {
                    if (currentGuess.length > 0) {
                        currentGuess.pop();
                        updateDisplay();
                    }
                } else if (/^[A-Z]$/.test(key) && currentGuess.length < 5) {
                    currentGuess.push(key);
                    updateDisplay();
                }
            }
            
            function updateDisplay() {
                for (let i = 0; i < 5; i++) {
                    const tile = document.getElementById(`tile-${currentRow}-${i}`);
                    tile.textContent = currentGuess[i] || '';
                }
            }
            
            function checkGuess() {
                const guess = currentGuess.join('');
                const targetArray = TARGET_WORD.split('');
                const guessArray = guess.split('');
                const result = Array(5).fill('absent');
                
                // Check for correct letters
                for (let i = 0; i < 5; i++) {
                    if (guessArray[i] === targetArray[i]) {
                        result[i] = 'correct';
                        targetArray[i] = null;
                        guessArray[i] = null;
                    }
                }
                
                // Check for present letters
                for (let i = 0; i < 5; i++) {
                    if (guessArray[i] && targetArray.includes(guessArray[i])) {
                        result[i] = 'present';
                        targetArray[targetArray.indexOf(guessArray[i])] = null;
                    }
                }
                
                // Apply results with animation
                for (let i = 0; i < 5; i++) {
                    setTimeout(() => {
                        const tile = document.getElementById(`tile-${currentRow}-${i}`);
                        tile.className = `tile ${result[i]}`;
                    }, i * 100);
                }
                
                // Check win/lose condition
                if (guess === TARGET_WORD) {
                    setTimeout(() => showMessage('🎉 You won! 🎉'), 600);
                    gameOver = true;
                } else if (currentRow === 5) {
                    setTimeout(() => showMessage(`😞 The word was ${TARGET_WORD}`), 600);
                    gameOver = true;
                } else {
                    currentRow++;
                    currentGuess = [];
                }
            }
            
            function showMessage(text) {
                const message = document.createElement('div');
                message.className = 'message';
                message.textContent = text;
                document.body.appendChild(message);
                
                setTimeout(() => {
                    document.body.removeChild(message);
                }, 2000);
            }
        </script>
    </body>
    </html>
    """
    
    // MARK: - 2048 Game
    static let game2048 = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>2048</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%);
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                color: #776e65;
                touch-action: manipulation;
            }
            .game-container {
                text-align: center;
                padding: 20px;
            }
            h1 {
                font-size: 3em;
                color: #776e65;
                margin-bottom: 10px;
            }
            .score {
                font-size: 1.2em;
                margin-bottom: 20px;
                font-weight: bold;
            }
            .grid {
                position: relative;
                background: #bbada0;
                border-radius: 10px;
                width: 350px;
                height: 350px;
                margin: 0 auto;
                padding: 10px;
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                grid-template-rows: repeat(4, 1fr);
                gap: 10px;
            }
            .cell {
                background: #cdc1b4;
                border-radius: 6px;
                position: relative;
            }
            .tile {
                position: absolute;
                background: #eee4da;
                border-radius: 6px;
                display: flex;
                justify-content: center;
                align-items: center;
                font-size: 2em;
                font-weight: bold;
                color: #776e65;
                transition: all 0.15s ease-in-out;
                width: calc(25% - 7.5px);
                height: calc(25% - 7.5px);
            }
            .tile-2 { background: #eee4da; color: #776e65; }
            .tile-4 { background: #ede0c8; color: #776e65; }
            .tile-8 { background: #f2b179; color: #f9f6f2; }
            .tile-16 { background: #f59563; color: #f9f6f2; }
            .tile-32 { background: #f67c5f; color: #f9f6f2; }
            .tile-64 { background: #f65e3b; color: #f9f6f2; }
            .tile-128 { background: #edcf72; color: #f9f6f2; font-size: 1.7em; }
            .tile-256 { background: #edcc61; color: #f9f6f2; font-size: 1.7em; }
            .tile-512 { background: #edc850; color: #f9f6f2; font-size: 1.7em; }
            .tile-1024 { background: #edc53f; color: #f9f6f2; font-size: 1.4em; }
            .tile-2048 { background: #edc22e; color: #f9f6f2; font-size: 1.4em; }
            .instructions {
                margin-top: 20px;
                font-size: 1em;
                color: #776e65;
            }
            .restart-btn {
                margin-top: 20px;
                padding: 12px 24px;
                background: #8f7a66;
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 1em;
                cursor: pointer;
                transition: background 0.2s;
            }
            .restart-btn:hover {
                background: #9f8a76;
            }
            .game-over {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(0,0,0,0.8);
                color: white;
                padding: 30px;
                border-radius: 10px;
                text-align: center;
                z-index: 1000;
            }
        </style>
    </head>
    <body>
        <div class="game-container">
            <h1>2048</h1>
            <div class="score">Score: <span id="score">0</span></div>
            <div class="grid" id="grid"></div>
            <div class="instructions">
                Swipe or use arrow keys to move tiles<br>
                Combine tiles with the same number to reach 2048!
            </div>
            <button class="restart-btn" onclick="initGame()">New Game</button>
        </div>
        
        <script>
            let grid = Array(4).fill(null).map(() => Array(4).fill(0));
            let score = 0;
            let gameWon = false;
            
            const gridElement = document.getElementById('grid');
            const scoreElement = document.getElementById('score');
            
            // Initialize grid cells
            for (let i = 0; i < 16; i++) {
                const cell = document.createElement('div');
                cell.className = 'cell';
                gridElement.appendChild(cell);
            }
            
            // Touch handling
            let startX, startY;
            gridElement.addEventListener('touchstart', (e) => {
                e.preventDefault();
                startX = e.touches[0].clientX;
                startY = e.touches[0].clientY;
            }, {passive: false});
            
            gridElement.addEventListener('touchmove', (e) => {
                e.preventDefault();
            }, {passive: false});
            
            gridElement.addEventListener('touchend', (e) => {
                e.preventDefault();
                if (!startX || !startY) return;
                
                const endX = e.changedTouches[0].clientX;
                const endY = e.changedTouches[0].clientY;
                
                const diffX = startX - endX;
                const diffY = startY - endY;
                
                if (Math.abs(diffX) > Math.abs(diffY)) {
                    if (diffX > 30) move('left');
                    else if (diffX < -30) move('right');
                } else {
                    if (diffY > 30) move('up');
                    else if (diffY < -30) move('down');
                }
                
                startX = null;
                startY = null;
            }, {passive: false});
            
            // Keyboard handling
            document.addEventListener('keydown', (e) => {
                switch(e.key) {
                    case 'ArrowUp': e.preventDefault(); move('up'); break;
                    case 'ArrowDown': e.preventDefault(); move('down'); break;
                    case 'ArrowLeft': e.preventDefault(); move('left'); break;
                    case 'ArrowRight': e.preventDefault(); move('right'); break;
                }
            });
            
            function initGame() {
                grid = Array(4).fill(null).map(() => Array(4).fill(0));
                score = 0;
                gameWon = false;
                addRandomTile();
                addRandomTile();
                updateDisplay();
            }
            
            function addRandomTile() {
                const emptyCells = [];
                for (let i = 0; i < 4; i++) {
                    for (let j = 0; j < 4; j++) {
                        if (grid[i][j] === 0) emptyCells.push({x: i, y: j});
                    }
                }
                
                if (emptyCells.length > 0) {
                    const randomCell = emptyCells[Math.floor(Math.random() * emptyCells.length)];
                    grid[randomCell.x][randomCell.y] = Math.random() < 0.9 ? 2 : 4;
                }
            }
            
            function updateDisplay() {
                // Clear existing tiles
                const existingTiles = document.querySelectorAll('.tile');
                existingTiles.forEach(tile => tile.remove());
                
                // Create new tiles
                for (let i = 0; i < 4; i++) {
                    for (let j = 0; j < 4; j++) {
                        if (grid[i][j] !== 0) {
                            const tile = document.createElement('div');
                            tile.className = `tile tile-${grid[i][j]}`;
                            tile.textContent = grid[i][j];
                            tile.style.left = `${j * 25 + j * 2.5 + 2.5}%`;
                            tile.style.top = `${i * 25 + i * 2.5 + 2.5}%`;
                            gridElement.appendChild(tile);
                        }
                    }
                }
                
                scoreElement.textContent = score;
                
                if (isGameWon() && !gameWon) {
                    gameWon = true;
                    setTimeout(() => showGameOver('🎉 You won! 🎉'), 300);
                } else if (isGameOver()) {
                    setTimeout(() => showGameOver('Game Over!'), 300);
                }
            }
            
            function move(direction) {
                let moved = false;
                const newGrid = grid.map(row => [...row]);
                
                if (direction === 'left' || direction === 'right') {
                    for (let i = 0; i < 4; i++) {
                        const row = direction === 'left' ? newGrid[i] : newGrid[i].reverse();
                        const filteredRow = row.filter(cell => cell !== 0);
                        
                        for (let j = 0; j < filteredRow.length - 1; j++) {
                            if (filteredRow[j] === filteredRow[j + 1]) {
                                filteredRow[j] *= 2;
                                score += filteredRow[j];
                                filteredRow[j + 1] = 0;
                            }
                        }
                        
                        const finalRow = filteredRow.filter(cell => cell !== 0);
                        while (finalRow.length < 4) finalRow.push(0);
                        
                        newGrid[i] = direction === 'left' ? finalRow : finalRow.reverse();
                        
                        if (JSON.stringify(grid[i]) !== JSON.stringify(newGrid[i])) moved = true;
                    }
                } else {
                    for (let j = 0; j < 4; j++) {
                        const column = [];
                        for (let i = 0; i < 4; i++) {
                            column.push(newGrid[i][j]);
                        }
                        
                        const workingColumn = direction === 'up' ? column : column.reverse();
                        const filteredColumn = workingColumn.filter(cell => cell !== 0);
                        
                        for (let i = 0; i < filteredColumn.length - 1; i++) {
                            if (filteredColumn[i] === filteredColumn[i + 1]) {
                                filteredColumn[i] *= 2;
                                score += filteredColumn[i];
                                filteredColumn[i + 1] = 0;
                            }
                        }
                        
                        const finalColumn = filteredColumn.filter(cell => cell !== 0);
                        while (finalColumn.length < 4) finalColumn.push(0);
                        
                        const resultColumn = direction === 'up' ? finalColumn : finalColumn.reverse();
                        
                        for (let i = 0; i < 4; i++) {
                            if (newGrid[i][j] !== resultColumn[i]) moved = true;
                            newGrid[i][j] = resultColumn[i];
                        }
                    }
                }
                
                if (moved) {
                    grid = newGrid;
                    addRandomTile();
                    updateDisplay();
                }
            }
            
            function isGameWon() {
                for (let i = 0; i < 4; i++) {
                    for (let j = 0; j < 4; j++) {
                        if (grid[i][j] === 2048) return true;
                    }
                }
                return false;
            }
            
            function isGameOver() {
                // Check for empty cells
                for (let i = 0; i < 4; i++) {
                    for (let j = 0; j < 4; j++) {
                        if (grid[i][j] === 0) return false;
                    }
                }
                
                // Check for possible merges
                for (let i = 0; i < 4; i++) {
                    for (let j = 0; j < 4; j++) {
                        if (j < 3 && grid[i][j] === grid[i][j + 1]) return false;
                        if (i < 3 && grid[i][j] === grid[i + 1][j]) return false;
                    }
                }
                
                return true;
            }
            
            function showGameOver(message) {
                const gameOverDiv = document.createElement('div');
                gameOverDiv.className = 'game-over';
                gameOverDiv.innerHTML = `
                    <h2>${message}</h2>
                    <p>Final Score: ${score}</p>
                    <button class="restart-btn" onclick="this.parentNode.remove(); initGame();">Play Again</button>
                `;
                document.body.appendChild(gameOverDiv);
            }
            
            initGame();
        </script>
    </body>
    </html>
    """
    
    // MARK: - Snake Game
    static let snakeGame = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Snake Game</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: linear-gradient(135deg, #2d3748 0%, #1a202c 100%);
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                color: white;
                touch-action: manipulation;
            }
            .game-container {
                text-align: center;
                padding: 20px;
            }
            h1 {
                font-size: 3em;
                margin-bottom: 10px;
                background: linear-gradient(45deg, #48bb78, #38a169);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            .score {
                font-size: 1.5em;
                margin-bottom: 20px;
                font-weight: bold;
            }
            canvas {
                border: 3px solid #48bb78;
                border-radius: 10px;
                background: #2d3748;
                display: block;
                margin: 0 auto;
            }
            .controls {
                margin-top: 20px;
                display: grid;
                grid-template-columns: repeat(3, 60px);
                grid-template-rows: repeat(3, 60px);
                gap: 10px;
                justify-content: center;
                max-width: 200px;
                margin: 20px auto;
            }
            .control-btn {
                background: rgba(255,255,255,0.2);
                border: 2px solid rgba(255,255,255,0.3);
                border-radius: 10px;
                color: white;
                font-size: 1.2em;
                cursor: pointer;
                transition: all 0.2s;
                touch-action: manipulation;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .control-btn:hover {
                background: rgba(255,255,255,0.3);
            }
            .control-btn:active {
                transform: scale(0.95);
            }
            .control-btn.up { grid-column: 2; grid-row: 1; }
            .control-btn.left { grid-column: 1; grid-row: 2; }
            .control-btn.down { grid-column: 2; grid-row: 3; }
            .control-btn.right { grid-column: 3; grid-row: 2; }
            .restart-btn {
                margin-top: 20px;
                padding: 12px 24px;
                background: #48bb78;
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 1em;
                cursor: pointer;
                transition: background 0.2s;
            }
            .restart-btn:hover {
                background: #38a169;
            }
        </style>
    </head>
    <body>
        <div class="game-container">
            <h1>Snake</h1>
            <div class="score">Score: <span id="score">0</span></div>
            <canvas id="gameCanvas" width="400" height="400"></canvas>
            <div class="controls">
                <button class="control-btn up" onclick="changeDirection('up')">↑</button>
                <button class="control-btn left" onclick="changeDirection('left')">←</button>
                <button class="control-btn down" onclick="changeDirection('down')">↓</button>
                <button class="control-btn right" onclick="changeDirection('right')">→</button>
            </div>
            <button class="restart-btn" onclick="initGame()">New Game</button>
        </div>
        
        <script>
            const canvas = document.getElementById('gameCanvas');
            const ctx = canvas.getContext('2d');
            const scoreElement = document.getElementById('score');
            
            const gridSize = 20;
            const tileCount = canvas.width / gridSize;
            
            let snake = [{x: 10, y: 10}];
            let food = {};
            let dx = 0;
            let dy = 0;
            let score = 0;
            let gameRunning = false;
            
            function initGame() {
                snake = [{x: 10, y: 10}];
                dx = 0;
                dy = 0;
                score = 0;
                gameRunning = true;
                generateFood();
                updateScore();
                gameLoop();
            }
            
            function gameLoop() {
                if (!gameRunning) return;
                
                update();
                draw();
                
                setTimeout(gameLoop, 150);
            }
            
            function update() {
                const head = {x: snake[0].x + dx, y: snake[0].y + dy};
                
                // Check wall collisions
                if (head.x < 0 || head.x >= tileCount || head.y < 0 || head.y >= tileCount) {
                    gameOver();
                    return;
                }
                
                // Check self collision
                for (let segment of snake) {
                    if (head.x === segment.x && head.y === segment.y) {
                        gameOver();
                        return;
                    }
                }
                
                snake.unshift(head);
                
                // Check food collision
                if (head.x === food.x && head.y === food.y) {
                    score += 10;
                    updateScore();
                    generateFood();
                } else {
                    snake.pop();
                }
            }
            
            function draw() {
                // Clear canvas
                ctx.fillStyle = '#2d3748';
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                
                // Draw snake
                ctx.fillStyle = '#48bb78';
                for (let segment of snake) {
                    ctx.fillRect(segment.x * gridSize, segment.y * gridSize, gridSize - 2, gridSize - 2);
                }
                
                // Draw food
                ctx.fillStyle = '#f56565';
                ctx.fillRect(food.x * gridSize, food.y * gridSize, gridSize - 2, gridSize - 2);
            }
            
            function generateFood() {
                food = {
                    x: Math.floor(Math.random() * tileCount),
                    y: Math.floor(Math.random() * tileCount)
                };
                
                // Make sure food doesn't spawn on snake
                for (let segment of snake) {
                    if (segment.x === food.x && segment.y === food.y) {
                        generateFood();
                        return;
                    }
                }
            }
            
            function changeDirection(direction) {
                if (!gameRunning) {
                    initGame();
                    return;
                }
                
                switch (direction) {
                    case 'up':
                        if (dy === 0) { dx = 0; dy = -1; }
                        break;
                    case 'down':
                        if (dy === 0) { dx = 0; dy = 1; }
                        break;
                    case 'left':
                        if (dx === 0) { dx = -1; dy = 0; }
                        break;
                    case 'right':
                        if (dx === 0) { dx = 1; dy = 0; }
                        break;
                }
            }
            
            function updateScore() {
                scoreElement.textContent = score;
            }
            
            function gameOver() {
                gameRunning = false;
                ctx.fillStyle = 'rgba(0,0,0,0.7)';
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                
                ctx.fillStyle = 'white';
                ctx.font = '40px Arial';
                ctx.textAlign = 'center';
                ctx.fillText('Game Over!', canvas.width / 2, canvas.height / 2 - 20);
                
                ctx.font = '20px Arial';
                ctx.fillText(`Final Score: ${score}`, canvas.width / 2, canvas.height / 2 + 20);
                
                ctx.fillText('Tap any direction to restart', canvas.width / 2, canvas.height / 2 + 50);
            }
            
            // Keyboard controls
            document.addEventListener('keydown', (e) => {
                switch(e.key) {
                    case 'ArrowUp': e.preventDefault(); changeDirection('up'); break;
                    case 'ArrowDown': e.preventDefault(); changeDirection('down'); break;
                    case 'ArrowLeft': e.preventDefault(); changeDirection('left'); break;
                    case 'ArrowRight': e.preventDefault(); changeDirection('right'); break;
                }
            });
            
            // Touch controls
            let touchStartX = 0;
            let touchStartY = 0;
            
            canvas.addEventListener('touchstart', (e) => {
                e.preventDefault();
                touchStartX = e.touches[0].clientX;
                touchStartY = e.touches[0].clientY;
            }, {passive: false});
            
            canvas.addEventListener('touchend', (e) => {
                e.preventDefault();
                const touchEndX = e.changedTouches[0].clientX;
                const touchEndY = e.changedTouches[0].clientY;
                
                const diffX = touchStartX - touchEndX;
                const diffY = touchStartY - touchEndY;
                
                if (Math.abs(diffX) > Math.abs(diffY)) {
                    if (diffX > 30) changeDirection('left');
                    else if (diffX < -30) changeDirection('right');
                } else {
                    if (diffY > 30) changeDirection('up');
                    else if (diffY < -30) changeDirection('down');
                }
            }, {passive: false});
            
            initGame();
        </script>
    </body>
    </html>
    """
    
    // MARK: - Simple Tetris
    static let tetrisGame = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tetris</title>
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
            .game-container {
                text-align: center;
                padding: 20px;
            }
            h1 {
                font-size: 3em;
                margin-bottom: 10px;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            }
            .score {
                font-size: 1.5em;
                margin-bottom: 20px;
                font-weight: bold;
            }
            canvas {
                border: 3px solid white;
                border-radius: 10px;
                background: #000;
                display: block;
                margin: 0 auto;
                box-shadow: 0 10px 20px rgba(0,0,0,0.3);
            }
            .controls {
                margin-top: 20px;
                display: grid;
                grid-template-columns: repeat(4, 60px);
                grid-template-rows: repeat(2, 60px);
                gap: 10px;
                justify-content: center;
                max-width: 260px;
                margin: 20px auto;
            }
            .control-btn {
                background: rgba(255,255,255,0.2);
                border: 2px solid rgba(255,255,255,0.3);
                border-radius: 10px;
                color: white;
                font-size: 1em;
                cursor: pointer;
                transition: all 0.2s;
                touch-action: manipulation;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
            }
            .control-btn:hover {
                background: rgba(255,255,255,0.3);
            }
            .control-btn:active {
                transform: scale(0.95);
            }
            .restart-btn {
                margin-top: 20px;
                padding: 12px 24px;
                background: #667eea;
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 1em;
                cursor: pointer;
                transition: background 0.2s;
            }
            .restart-btn:hover {
                background: #5a6bd8;
            }
        </style>
    </head>
    <body>
        <div class="game-container">
            <h1>Tetris</h1>
            <div class="score">Score: <span id="score">0</span></div>
            <canvas id="gameCanvas" width="300" height="600"></canvas>
            <div class="controls">
                <button class="control-btn" onclick="movePiece(-1, 0)">←</button>
                <button class="control-btn" onclick="rotatePiece()">↻</button>
                <button class="control-btn" onclick="movePiece(1, 0)">→</button>
                <button class="control-btn" onclick="dropPiece()">↓</button>
            </div>
            <button class="restart-btn" onclick="initGame()">New Game</button>
        </div>
        
        <script>
            const canvas = document.getElementById('gameCanvas');
            const ctx = canvas.getContext('2d');
            const scoreElement = document.getElementById('score');
            
            const BOARD_WIDTH = 10;
            const BOARD_HEIGHT = 20;
            const BLOCK_SIZE = 30;
            
            let board = Array(BOARD_HEIGHT).fill().map(() => Array(BOARD_WIDTH).fill(0));
            let score = 0;
            let gameRunning = false;
            let currentPiece = null;
            let dropTime = 0;
            
            const PIECES = [
                {shape: [[1,1,1,1]], color: '#00f0f0'}, // I
                {shape: [[1,1],[1,1]], color: '#f0f000'}, // O
                {shape: [[0,1,0],[1,1,1]], color: '#a000f0'}, // T
                {shape: [[0,1,1],[1,1,0]], color: '#00f000'}, // S
                {shape: [[1,1,0],[0,1,1]], color: '#f00000'}, // Z
                {shape: [[1,0,0],[1,1,1]], color: '#f0a000'}, // L
                {shape: [[0,0,1],[1,1,1]], color: '#0000f0'}  // J
            ];
            
            function initGame() {
                board = Array(BOARD_HEIGHT).fill().map(() => Array(BOARD_WIDTH).fill(0));
                score = 0;
                gameRunning = true;
                updateScore();
                spawnPiece();
                gameLoop();
            }
            
            function gameLoop() {
                if (!gameRunning) return;
                
                const now = Date.now();
                if (now - dropTime > 1000) {
                    if (!movePiece(0, 1)) {
                        placePiece();
                        clearLines();
                        spawnPiece();
                        if (isGameOver()) {
                            gameOver();
                            return;
                        }
                    }
                    dropTime = now;
                }
                
                draw();
                requestAnimationFrame(gameLoop);
            }
            
            function spawnPiece() {
                const pieceType = PIECES[Math.floor(Math.random() * PIECES.length)];
                currentPiece = {
                    shape: pieceType.shape.map(row => [...row]),
                    color: pieceType.color,
                    x: Math.floor(BOARD_WIDTH / 2) - Math.floor(pieceType.shape[0].length / 2),
                    y: 0
                };
            }
            
            function movePiece(dx, dy) {
                if (!currentPiece) return false;
                
                const newX = currentPiece.x + dx;
                const newY = currentPiece.y + dy;
                
                if (isValidPosition(currentPiece.shape, newX, newY)) {
                    currentPiece.x = newX;
                    currentPiece.y = newY;
                    return true;
                }
                return false;
            }
            
            function rotatePiece() {
                if (!currentPiece) return;
                
                const rotated = currentPiece.shape[0].map((_, i) =>
                    currentPiece.shape.map(row => row[i]).reverse()
                );
                
                if (isValidPosition(rotated, currentPiece.x, currentPiece.y)) {
                    currentPiece.shape = rotated;
                }
            }
            
            function dropPiece() {
                if (!currentPiece) return;
                
                while (movePiece(0, 1)) {
                    score += 2;
                }
                updateScore();
            }
            
            function isValidPosition(shape, x, y) {
                for (let row = 0; row < shape.length; row++) {
                    for (let col = 0; col < shape[row].length; col++) {
                        if (shape[row][col]) {
                            const newX = x + col;
                            const newY = y + row;
                            
                            if (newX < 0 || newX >= BOARD_WIDTH || 
                                newY >= BOARD_HEIGHT ||
                                (newY >= 0 && board[newY][newX])) {
                                return false;
                            }
                        }
                    }
                }
                return true;
            }
            
            function placePiece() {
                if (!currentPiece) return;
                
                for (let row = 0; row < currentPiece.shape.length; row++) {
                    for (let col = 0; col < currentPiece.shape[row].length; col++) {
                        if (currentPiece.shape[row][col]) {
                            const x = currentPiece.x + col;
                            const y = currentPiece.y + row;
                            if (y >= 0) {
                                board[y][x] = currentPiece.color;
                            }
                        }
                    }
                }
                currentPiece = null;
            }
            
            function clearLines() {
                let linesCleared = 0;
                
                for (let row = BOARD_HEIGHT - 1; row >= 0; row--) {
                    if (board[row].every(cell => cell !== 0)) {
                        board.splice(row, 1);
                        board.unshift(Array(BOARD_WIDTH).fill(0));
                        linesCleared++;
                        row++; // Check the same row again
                    }
                }
                
                if (linesCleared > 0) {
                    score += linesCleared * 100 * linesCleared; // Bonus for multiple lines
                    updateScore();
                }
            }
            
            function isGameOver() {
                return board[0].some(cell => cell !== 0);
            }
            
            function draw() {
                // Clear canvas
                ctx.fillStyle = '#000';
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                
                // Draw board
                for (let row = 0; row < BOARD_HEIGHT; row++) {
                    for (let col = 0; col < BOARD_WIDTH; col++) {
                        if (board[row][col]) {
                            ctx.fillStyle = board[row][col];
                            ctx.fillRect(col * BLOCK_SIZE, row * BLOCK_SIZE, 
                                       BLOCK_SIZE - 1, BLOCK_SIZE - 1);
                        }
                    }
                }
                
                // Draw current piece
                if (currentPiece) {
                    ctx.fillStyle = currentPiece.color;
                    for (let row = 0; row < currentPiece.shape.length; row++) {
                        for (let col = 0; col < currentPiece.shape[row].length; col++) {
                            if (currentPiece.shape[row][col]) {
                                const x = (currentPiece.x + col) * BLOCK_SIZE;
                                const y = (currentPiece.y + row) * BLOCK_SIZE;
                                ctx.fillRect(x, y, BLOCK_SIZE - 1, BLOCK_SIZE - 1);
                            }
                        }
                    }
                }
            }
            
            function updateScore() {
                scoreElement.textContent = score;
            }
            
            function gameOver() {
                gameRunning = false;
                ctx.fillStyle = 'rgba(0,0,0,0.8)';
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                
                ctx.fillStyle = 'white';
                ctx.font = '30px Arial';
                ctx.textAlign = 'center';
                ctx.fillText('Game Over!', canvas.width / 2, canvas.height / 2 - 30);
                
                ctx.font = '20px Arial';
                ctx.fillText(`Final Score: ${score}`, canvas.width / 2, canvas.height / 2 + 10);
            }
            
            // Keyboard controls
            document.addEventListener('keydown', (e) => {
                if (!gameRunning) return;
                
                switch(e.key) {
                    case 'ArrowLeft': e.preventDefault(); movePiece(-1, 0); break;
                    case 'ArrowRight': e.preventDefault(); movePiece(1, 0); break;
                    case 'ArrowDown': e.preventDefault(); movePiece(0, 1); break;
                    case 'ArrowUp': e.preventDefault(); rotatePiece(); break;
                    case ' ': e.preventDefault(); dropPiece(); break;
                }
            });
            
            initGame();
        </script>
    </body>
    </html>
    """
    
    // MARK: - Simple Test Game
    static let simpleTestGame = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Test Game</title>
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
                padding: 20px;
            }
            .game-container {
                text-align: center;
                max-width: 400px;
                width: 100%;
            }
            h1 {
                font-size: 2.5em;
                margin-bottom: 20px;
                background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            .score {
                font-size: 1.5em;
                margin-bottom: 30px;
                font-weight: bold;
            }
            button {
                background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
                border: none;
                padding: 20px 40px;
                border-radius: 25px;
                color: white;
                font-size: 1.2em;
                font-weight: bold;
                cursor: pointer;
                margin: 10px;
                transition: transform 0.2s;
                touch-action: manipulation;
            }
            button:active { transform: scale(0.95); }
            .status {
                margin-top: 20px;
                padding: 10px;
                background: rgba(255,255,255,0.1);
                border-radius: 10px;
            }
        </style>
    </head>
    <body>
        <div class="game-container">
            <h1>🎮 Test Game</h1>
            <div class="score">Score: <span id="score">0</span></div>
            <button onclick="increaseScore()">Click to Play!</button>
            <button onclick="resetGame()">Reset Game</button>
            <div class="status" id="status">Game loaded successfully! ✅</div>
        </div>
        
        <script>
            let score = 0;
            
            function increaseScore() {
                score++;
                updateScore();
                updateStatus();
            }
            
            function resetGame() {
                score = 0;
                updateScore();
                document.getElementById('status').innerHTML = 'Game reset! Ready to play again. 🎯';
            }
            
            function updateScore() {
                document.getElementById('score').textContent = score;
            }
            
            function updateStatus() {
                const statusEl = document.getElementById('status');
                if (score === 1) {
                    statusEl.innerHTML = 'Great! Touch controls are working! 👍';
                } else if (score === 5) {
                    statusEl.innerHTML = 'Awesome! You\\'re on fire! 🔥';
                } else if (score === 10) {
                    statusEl.innerHTML = '🎉 Perfect! Game is fully functional! 🎉';
                } else if (score > 10) {
                    statusEl.innerHTML = `Amazing! Score: ${score}! Keep going! 🚀`;
                }
            }
            
            // Test that JavaScript is working
            window.onload = function() {
                console.log('✅ Test game loaded successfully');
                document.getElementById('status').innerHTML = 'JavaScript is working! Ready to play! 🎮';
            }
            
            // Handle touch events properly
            document.addEventListener('touchstart', function(e) {
                // Prevent default to ensure touch works properly
                if (e.target.tagName === 'BUTTON') {
                    e.preventDefault();
                }
            });
        </script>
    </body>
    </html>
    """
}