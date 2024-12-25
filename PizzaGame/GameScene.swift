//
//  GameScene.swift
//  PizzaGame
//
//  Created by 堀中　佳樹 on 2024/12/23.
//

import SpriteKit
import GameplayKit

// MARK: - GameScene
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    private var pizzaBase: SKSpriteNode!
    private var currentTopping: SKSpriteNode?
    private var gameOver = false
    private var lastRotationAngle: CGFloat = 0  // 回転操作用
    private var initialTouchPosition: CGPoint?   // 回転操作用
    private var lastTouchPosition: CGPoint?
    
    // 回転制御用のプロパティを追加
    private var touchMovementHistory: [CGPoint] = []
    private let movementHistoryLimit = 5 // 移動履歴の保持数
    private var isRotationMode = false
    private let rotationThreshold: CGFloat = 20 // 回転モード判定のための閾値
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    private let scoreLabel = SKLabelNode(fontNamed: "Arial")
    
    // Physics Categories
    private let toppingCategory: UInt32 = 0x1 << 0
    private let baseCategory: UInt32 = 0x1 << 1
    private let boundaryCategory: UInt32 = 0x1 << 2
    
    // Toppings
    private struct ToppingConfig {
            let name: String
            let size: CGSize
            let density: CGFloat  // 密度: より重いものは転がりにくい
            let restitution: CGFloat  // 反発係数: バウンドのしやすさ
            let friction: CGFloat  // 摩擦係数: 転がりやすさ
    }
        
    private let toppingsConfig = [
        ToppingConfig(name: "pineapple", size: CGSize(width: 100, height: 100), density: 2.0, restitution: 0.1, friction: 0.9),
        ToppingConfig(name: "tomato", size: CGSize(width: 80, height: 80), density: 1.8, restitution: 0.1, friction: 0.85),
        ToppingConfig(name: "olive", size: CGSize(width: 100, height: 100), density: 1.5, restitution: 0.1, friction: 0.8)
    ]
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupPizzaBase()
        setupScoreLabel()
        setupBoundaries()
        spawnNewTopping()
    }
    
    private func setupPhysicsWorld() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
//        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // 画面端に見えない壁を設置（当たり判定なし）
        let frame = SKPhysicsBody(edgeLoopFrom: self.frame)
        frame.categoryBitMask = 0 // カテゴリビットマスクを0に設定して当たり判定を無効化
        frame.collisionBitMask = 0 // 衝突ビットマスクも0に設定
        self.physicsBody = frame
    }
    
    private func setupPizzaBase() {
        let baseWidth = frame.width * 0.8
        let baseHeight: CGFloat = 10
//        let baseHeight: CGFloat = 20
        
                
        pizzaBase = SKSpriteNode(color: .brown, size: CGSize(width: baseWidth, height: baseHeight))
        pizzaBase.position = CGPoint(x: frame.midX, y: frame.height * 0.2)
        
//        // ピザ生地の物理形状を不規則な形に
//        let path = CGMutablePath()
//        let pointsCount = 20
//        var points: [CGPoint] = []
//        
//        // 不規則な凸凹を生成
//        for i in 0...pointsCount {
//            let x = CGFloat(i) * (baseWidth / CGFloat(pointsCount)) - baseWidth/2
//            let randomY = CGFloat.random(in: -2...2)
//            points.append(CGPoint(x: x, y: randomY))
//        }
        
        // デコボコした地形を作成
        let path = CGMutablePath()
        let segmentCount = 40  // より細かい分割
        let segmentWidth = baseWidth / CGFloat(segmentCount)
        var points: [CGPoint] = []
        
        // より自然なデコボコを生成
        for i in 0...segmentCount {
            let x = CGFloat(i) * segmentWidth - baseWidth/2
            // 最大2度の傾斜をランダムに生成
            let angle = CGFloat.random(in: -2...2) * .pi / 180
            let y = sin(angle) * 2  // 小さな起伏
            points.append(CGPoint(x: x, y: y))
        }
        
        // パスの生成
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        
        // ピザ生地の物理特性
        pizzaBase.physicsBody = SKPhysicsBody(rectangleOf: pizzaBase.size)
        pizzaBase.physicsBody?.isDynamic = false
        pizzaBase.physicsBody?.categoryBitMask = baseCategory
        pizzaBase.physicsBody?.contactTestBitMask = toppingCategory
        pizzaBase.physicsBody?.friction = 0.9 // 高い摩擦係数
        pizzaBase.physicsBody?.restitution = 0.1 // 低い反発係数
        
        addChild(pizzaBase)
    }
    
    private func setupScoreLabel() {
//        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
//        scoreLabel.position = CGPoint(x: frame.midX, y: frame.height - 50)
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.height * 0.15)
        addChild(scoreLabel)
    }
    
    private func setupBoundaries() {
        // 左右の境界線（見えない壁）を設定
//        let leftBoundary = SKNode()
//        leftBoundary.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: frame.height))
//        leftBoundary.physicsBody?.categoryBitMask = boundaryCategory
//        leftBoundary.physicsBody?.friction = 0.5
//        addChild(leftBoundary)
//        
//        let rightBoundary = SKNode()
//        rightBoundary.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.width, y: 0), to: CGPoint(x: frame.width, y: frame.height))
//        rightBoundary.physicsBody?.categoryBitMask = boundaryCategory
//        rightBoundary.physicsBody?.friction = 0.5
//        addChild(rightBoundary)
        let leftBoundary = SKNode()
        leftBoundary.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: frame.height))
        leftBoundary.physicsBody?.categoryBitMask = boundaryCategory
        leftBoundary.physicsBody?.friction = 0.5
        addChild(leftBoundary)
        
        let rightBoundary = SKNode()
        rightBoundary.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.width, y: 0), to: CGPoint(x: frame.width, y: frame.height))
        rightBoundary.physicsBody?.categoryBitMask = boundaryCategory
        rightBoundary.physicsBody?.friction = 0.5
        addChild(rightBoundary)
    }
    
    // MARK: - Game Logic
    
    private func createToppingPhysicsBody(for texture: SKTexture, config: ToppingConfig) -> SKPhysicsBody {
            // テクスチャからアルファチャンネルに基づいて物理形状を生成
            let physicsBody = SKPhysicsBody(texture: texture, size: config.size)
            
            // 物理特性の設定
            physicsBody.mass = 1.0 // 0.1
            physicsBody.density = config.density
            physicsBody.restitution = config.restitution
            physicsBody.friction = config.friction
            physicsBody.allowsRotation = true
            physicsBody.angularDamping = 0.9 // 回転の減衰
            physicsBody.linearDamping = 0.8 // 移動の減衰
            
            return physicsBody
        }
    
    private func spawnNewTopping() {
        guard !gameOver else { return }
        
        // ランダムな具材の設定を選択
        let config = toppingsConfig.randomElement()!
        
        // 具材のスプライトを作成
        let texture = SKTexture(imageNamed: config.name)
        let topping = SKSpriteNode(texture: texture, size: config.size)
        topping.position = CGPoint(x: frame.midX, y: frame.height - 100)
        
        // 透過画像に基づいた物理ボディを設定
        let physicsBody = createToppingPhysicsBody(for: texture, config: config)
        topping.physicsBody = physicsBody
        
        // 物理演算カテゴリの設定
        topping.physicsBody?.categoryBitMask = toppingCategory
        topping.physicsBody?.contactTestBitMask = baseCategory | boundaryCategory
        topping.physicsBody?.collisionBitMask = baseCategory | boundaryCategory | toppingCategory
        topping.physicsBody?.isDynamic = false
        
        // 初期回転角をランダムに設定
        topping.zRotation = CGFloat.random(in: 0...(2 * .pi))
        
        currentTopping = topping
        addChild(topping)
    }
    
    // MARK: - Touch Handling
    
    override func update(_ currentTime: TimeInterval) {
        // 画面下部からの落下チェック
//        if let topping = currentTopping, topping.physicsBody?.isDynamic == true {
//            if topping.position.y < 0 {  // 画面下部より下に行った場合
//                gameOver = true
//                showGameOver()
//                self.isPaused = true  // ゲームを停止
//            }
//        }
        if let topping = currentTopping, topping.physicsBody?.isDynamic == true {
            if topping.position.y < 0 {  // 画面下部より下に行った場合
                if !gameOver {
                    gameOver = true
                    showGameOver()
                    self.isPaused = true
                }
            }
        }
        
        // 画面外に出た具材の位置を補正（左右の移動を可能に）
        if let topping = currentTopping, topping.physicsBody?.isDynamic == true {
            if topping.position.x < 0 {
                topping.position.x = frame.width
            } else if topping.position.x > frame.width {
                topping.position.x = 0
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        
//        if let topping = currentTopping, !topping.physicsBody!.isDynamic {
//            initialTouchPosition = location
//            lastRotationAngle = atan2(location.y - topping.position.y,
//                                    location.x - topping.position.x)
//        }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if gameOver {
            resetGame()
            return
        }
        
        if let topping = currentTopping, !topping.physicsBody!.isDynamic {
            initialTouchPosition = location
            lastTouchPosition = location
            touchMovementHistory.removeAll()
            touchMovementHistory.append(location)
            isRotationMode = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let topping = currentTopping,
              !topping.physicsBody!.isDynamic,
              let lastTouch = lastTouchPosition else { return }
        
        let location = touch.location(in: self)
        touchMovementHistory.append(location)
        if touchMovementHistory.count > movementHistoryLimit {
            touchMovementHistory.removeFirst()
        }
        
        // 移動パターンの判定
        if !isRotationMode {
            isRotationMode = checkForRotationPattern()
        }
        
        // 位置の更新（左右移動）
        topping.position.x = location.x
        
        if isRotationMode {
            // 回転モードの場合、回転を適用
            let deltaX = location.x - lastTouch.x
            let deltaY = location.y - lastTouch.y
            let rotation = atan2(deltaY, deltaX)
            topping.zRotation += rotation * 0.3 // 回転速度を調整
        }
        
        lastTouchPosition = location
    }
    
    private func checkForRotationPattern() -> Bool {
        guard touchMovementHistory.count >= 3 else { return false }
        
        // 移動パターンの分析
        var totalVerticalMovement: CGFloat = 0
        for i in 1..<touchMovementHistory.count {
            let previousPoint = touchMovementHistory[i-1]
            let currentPoint = touchMovementHistory[i]
            totalVerticalMovement += abs(currentPoint.y - previousPoint.y)
        }
        
        // 垂直方向の移動が閾値を超えていれば回転モードと判定
        return totalVerticalMovement > rotationThreshold
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let topping = currentTopping {
            if !topping.physicsBody!.isDynamic {
                // 具材を落下させる
                topping.physicsBody?.isDynamic = true
                
//                // わずかな初期回転力を加える
//                if isRotationMode {
//                    let smallTorque = CGFloat.random(in: -0.2...0.2)
//                    topping.physicsBody?.applyTorque(smallTorque)
//                }
                
                // 新しい具材を生成
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.spawnNewTopping()
                }
                
                score += 10
            }
        }
        
        initialTouchPosition = nil
        lastTouchPosition = nil
        touchMovementHistory.removeAll()
        isRotationMode = false
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (toppingCategory | boundaryCategory) {
            // 具材が左右の境界に触れた場合、ゲームオーバー
            gameOver = true
            showGameOver()
        }
    }
    
    private func showGameOver() {
        let gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 48
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.name = "gameOver"
        addChild(gameOverLabel)
        
        // リスタートボタン
        let restartButton = SKLabelNode(fontNamed: "Arial")
        restartButton.text = "Tap to Restart"
        restartButton.fontSize = 24
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        restartButton.name = "restart"
        addChild(restartButton)
    }
    
    // MARK: - Game Reset
    private func resetGame() {
        // ゲームの状態をリセット
        gameOver = false
        score = 0
//        scoreLabel.text = "Score: 0"
        self.isPaused = false
        
        // 既存の具材を削除
        enumerateChildNodes(withName: "//") { node, _ in
            if node != self.pizzaBase && node != self.scoreLabel {
                node.removeFromParent()
            }
        }
        
        // 新しい具材を生成
        spawnNewTopping()
    }
}
