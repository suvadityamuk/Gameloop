//
//  MiniGamesExtra.swift  
//  Gameloop
//
//  Created by Suvaditya Mukherjee on 8/9/25.
//

import Foundation

extension MiniGames {
    
    // MARK: - Three.js Space Explorer Game (CPU-optimized)
    static let threeJSSpaceGame = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Space Explorer 3D</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: linear-gradient(135deg, #0c0c0c 0%, #1a1a2e 100%);
                overflow: hidden;
                color: white;
                touch-action: none;
            }
            #gameContainer {
                position: relative;
                width: 100vw;
                height: 100vh;
            }
            #ui {
                position: absolute;
                top: 20px;
                left: 20px;
                z-index: 100;
                font-size: 18px;
                font-weight: bold;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
            }
            #controls {
                position: absolute;
                bottom: 30px;
                left: 50%;
                transform: translateX(-50%);
                z-index: 100;
                display: grid;
                grid-template-columns: repeat(3, 60px);
                grid-template-rows: repeat(2, 60px);
                gap: 10px;
                opacity: 0.8;
            }
            .control-btn {
                background: rgba(255,255,255,0.2);
                border: 2px solid rgba(255,255,255,0.3);
                border-radius: 12px;
                color: white;
                font-size: 1.2em;
                cursor: pointer;
                transition: all 0.2s;
                touch-action: manipulation;
                display: flex;
                align-items: center;
                justify-content: center;
                user-select: none;
            }
            .control-btn:active {
                background: rgba(255,255,255,0.4);
                transform: scale(0.95);
            }
            .up { grid-column: 2; grid-row: 1; }
            .left { grid-column: 1; grid-row: 2; }
            .right { grid-column: 3; grid-row: 2; }
            #gameOver {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(0,0,0,0.9);
                padding: 40px;
                border-radius: 15px;
                text-align: center;
                z-index: 200;
                display: none;
            }
            #gameOver button {
                margin-top: 20px;
                padding: 12px 24px;
                background: #4CAF50;
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 16px;
                cursor: pointer;
            }
            .loading {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                text-align: center;
                z-index: 300;
            }
        </style>
    </head>
    <body>
        <div id="gameContainer">
            <div class="loading" id="loading">
                <h2>Loading Space Explorer...</h2>
                <p>Optimizing for your device...</p>
            </div>
            
            <div id="ui" style="display: none;">
                <div>Score: <span id="score">0</span></div>
                <div>Health: <span id="health">100</span></div>
            </div>
            
            <div id="controls" style="display: none;">
                <button class="control-btn up" id="upBtn">↑</button>
                <button class="control-btn left" id="leftBtn">←</button>
                <button class="control-btn right" id="rightBtn">→</button>
            </div>
            
            <div id="gameOver">
                <h2>Mission Complete!</h2>
                <p id="finalScore">Final Score: 0</p>
                <button onclick="restartGame()">Play Again</button>
            </div>
        </div>
        
        <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r152/three.min.js"></script>
        
        <script>
            let scene, camera, renderer, ship, stars = [], asteroids = [];
            let score = 0, health = 100, gameRunning = false;
            let keys = {};
            let particleSystem;
            let shipVelocity = { x: 0, y: 0, z: 0 };
            let cameraOffset = { x: 0, y: 2, z: 5 };
            
            const MAX_STARS = 80;
            const MAX_ASTEROIDS = 6;
            const SHIP_SPEED = 0.12;
            const ASTEROID_SPEED = 0.06;
            
            function init() {
                scene = new THREE.Scene();
                scene.fog = new THREE.Fog(0x000011, 50, 180);
                
                camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
                
                renderer = new THREE.WebGLRenderer({ 
                    antialias: false,
                    powerPreference: "low-power"
                });
                renderer.setSize(window.innerWidth, window.innerHeight);
                renderer.setClearColor(0x000011);
                renderer.shadowMap.enabled = false;
                document.getElementById('gameContainer').appendChild(renderer.domElement);
                
                const shipGeometry = new THREE.ConeGeometry(0.5, 2, 6);
                const shipMaterial = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
                ship = new THREE.Mesh(shipGeometry, shipMaterial);
                ship.position.set(0, 0, 0);
                ship.rotation.x = Math.PI / 2;
                scene.add(ship);
                
                createStarfield();
                createParticleSystem();
                setupControls();
                
                document.getElementById('loading').style.display = 'none';
                document.getElementById('ui').style.display = 'block';
                document.getElementById('controls').style.display = 'grid';
                
                gameRunning = true;
                gameLoop();
            }
            
            function createStarfield() {
                const starGeometry = new THREE.BufferGeometry();
                const starPositions = [];
                
                for (let i = 0; i < MAX_STARS; i++) {
                    starPositions.push(
                        (Math.random() - 0.5) * 180,
                        (Math.random() - 0.5) * 180,
                        (Math.random() - 0.5) * 180
                    );
                }
                
                starGeometry.setAttribute('position', new THREE.Float32BufferAttribute(starPositions, 3));
                const starMaterial = new THREE.PointsMaterial({ color: 0xffffff, size: 1.5 });
                const starfield = new THREE.Points(starGeometry, starMaterial);
                scene.add(starfield);
                stars.push(starfield);
            }
            
            function createParticleSystem() {
                const particleCount = 15;
                const particleGeometry = new THREE.BufferGeometry();
                const particlePositions = [];
                
                for (let i = 0; i < particleCount; i++) {
                    particlePositions.push(0, 0, 0);
                }
                
                particleGeometry.setAttribute('position', new THREE.Float32BufferAttribute(particlePositions, 3));
                const particleMaterial = new THREE.PointsMaterial({ 
                    color: 0x0099ff, 
                    size: 2.5,
                    transparent: true,
                    opacity: 0.7
                });
                
                particleSystem = new THREE.Points(particleGeometry, particleMaterial);
                scene.add(particleSystem);
            }
            
            function setupControls() {
                ['upBtn', 'leftBtn', 'rightBtn'].forEach(id => {
                    const btn = document.getElementById(id);
                    const key = id.replace('Btn', '');
                    btn.addEventListener('touchstart', (e) => {
                        e.preventDefault();
                        keys[key] = true;
                    });
                    btn.addEventListener('touchend', (e) => {
                        e.preventDefault();
                        keys[key] = false;
                    });
                });
                
                window.addEventListener('keydown', (e) => {
                    switch(e.code) {
                        case 'ArrowUp': case 'KeyW': keys['up'] = true; break;
                        case 'ArrowLeft': case 'KeyA': keys['left'] = true; break;
                        case 'ArrowRight': case 'KeyD': keys['right'] = true; break;
                    }
                });
                
                window.addEventListener('keyup', (e) => {
                    switch(e.code) {
                        case 'ArrowUp': case 'KeyW': keys['up'] = false; break;
                        case 'ArrowLeft': case 'KeyA': keys['left'] = false; break;
                        case 'ArrowRight': case 'KeyD': keys['right'] = false; break;
                    }
                });
            }
            
            function spawnAsteroid() {
                if (asteroids.length >= MAX_ASTEROIDS) return;
                
                const size = Math.random() * 1.2 + 0.6;
                const asteroidGeometry = new THREE.IcosahedronGeometry(size, 0);
                const asteroidMaterial = new THREE.MeshBasicMaterial({ 
                    color: new THREE.Color().setHSL(Math.random() * 0.1, 0.8, 0.6),
                    wireframe: true
                });
                
                const asteroid = new THREE.Mesh(asteroidGeometry, asteroidMaterial);
                asteroid.position.set(
                    (Math.random() - 0.5) * 16,
                    (Math.random() - 0.5) * 16,
                    -40
                );
                asteroid.rotation.set(
                    Math.random() * Math.PI * 2,
                    Math.random() * Math.PI * 2,
                    Math.random() * Math.PI * 2
                );
                asteroid.userData = {
                    rotationSpeed: {
                        x: (Math.random() - 0.5) * 0.015,
                        y: (Math.random() - 0.5) * 0.015,
                        z: (Math.random() - 0.5) * 0.015
                    }
                };
                
                scene.add(asteroid);
                asteroids.push(asteroid);
            }
            
            function updateShip() {
                if (!gameRunning) return;
                
                if (keys['left']) shipVelocity.x -= SHIP_SPEED;
                if (keys['right']) shipVelocity.x += SHIP_SPEED;
                if (keys['up']) shipVelocity.y += SHIP_SPEED;
                
                shipVelocity.x *= 0.92;
                shipVelocity.y *= 0.92;
                
                ship.position.x += shipVelocity.x;
                ship.position.y += shipVelocity.y;
                
                ship.position.x = Math.max(-8, Math.min(8, ship.position.x));
                ship.position.y = Math.max(-6, Math.min(6, ship.position.y));
                
                camera.position.x += (ship.position.x + cameraOffset.x - camera.position.x) * 0.08;
                camera.position.y += (ship.position.y + cameraOffset.y - camera.position.y) * 0.08;
                camera.position.z = ship.position.z + cameraOffset.z;
                camera.lookAt(ship.position);
                
                updateParticleTrail();
            }
            
            function updateParticleTrail() {
                if (!particleSystem) return;
                
                const positions = particleSystem.geometry.attributes.position.array;
                
                for (let i = positions.length - 3; i >= 3; i -= 3) {
                    positions[i] = positions[i - 3];
                    positions[i + 1] = positions[i - 2];
                    positions[i + 2] = positions[i - 1];
                }
                
                positions[0] = ship.position.x + (Math.random() - 0.5) * 0.15;
                positions[1] = ship.position.y + (Math.random() - 0.5) * 0.15;
                positions[2] = ship.position.z - 0.8;
                
                particleSystem.geometry.attributes.position.needsUpdate = true;
            }
            
            function updateAsteroids() {
                for (let i = asteroids.length - 1; i >= 0; i--) {
                    const asteroid = asteroids[i];
                    
                    asteroid.position.z += ASTEROID_SPEED;
                    
                    asteroid.rotation.x += asteroid.userData.rotationSpeed.x;
                    asteroid.rotation.y += asteroid.userData.rotationSpeed.y;
                    asteroid.rotation.z += asteroid.userData.rotationSpeed.z;
                    
                    const distance = asteroid.position.distanceTo(ship.position);
                    if (distance < 1.5) {
                        health -= 15;
                        updateUI();
                        
                        scene.remove(asteroid);
                        asteroids.splice(i, 1);
                        
                        if (health <= 0) {
                            endGame();
                        }
                    }
                    else if (asteroid.position.z > 8) {
                        scene.remove(asteroid);
                        asteroids.splice(i, 1);
                        score += 15;
                        updateUI();
                    }
                }
                
                if (Math.random() < 0.015) {
                    spawnAsteroid();
                }
            }
            
            function updateUI() {
                document.getElementById('score').textContent = score;
                document.getElementById('health').textContent = Math.max(0, health);
            }
            
            function gameLoop() {
                if (!gameRunning) return;
                
                updateShip();
                updateAsteroids();
                
                score += 1;
                if (score % 120 === 0) {
                    updateUI();
                }
                
                renderer.render(scene, camera);
                requestAnimationFrame(gameLoop);
            }
            
            function endGame() {
                gameRunning = false;
                document.getElementById('finalScore').textContent = `Final Score: ${score}`;
                document.getElementById('gameOver').style.display = 'block';
            }
            
            function restartGame() {
                score = 0;
                health = 100;
                shipVelocity = { x: 0, y: 0, z: 0 };
                
                asteroids.forEach(asteroid => scene.remove(asteroid));
                asteroids = [];
                
                ship.position.set(0, 0, 0);
                camera.position.set(0, 2, 5);
                
                document.getElementById('gameOver').style.display = 'none';
                
                gameRunning = true;
                updateUI();
                gameLoop();
            }
            
            window.addEventListener('resize', () => {
                camera.aspect = window.innerWidth / window.innerHeight;
                camera.updateProjectionMatrix();
                renderer.setSize(window.innerWidth, window.innerHeight);
            });
            
            document.addEventListener('contextmenu', (e) => e.preventDefault());
            
            init();
        </script>
    </body>
    </html>
    """
    
    // MARK: - Get All Games Including Three.js
    static func getAllMiniGames() -> [(String, String, String)] {
        return [
            ("🎮 Test Game", simpleTestGame, "@testdev"),
            ("Wordle", wordleGame, "@wordmaster"),
            ("2048 Mobile", game2048, "@puzzlepro"),
            ("Snake Classic", snakeGame, "@retrodev"),
            ("Tetris Mini", tetrisGame, "@blockmaster"),
            ("Space Explorer 3D", threeJSSpaceGame, "@spacedev")
        ]
    }
}