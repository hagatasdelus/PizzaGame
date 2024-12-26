//
//  GameView.swift
//  PizzaGame
//
//  Created by 堀中　佳樹 on 2024/12/20.
//

import SwiftUI

struct GameView: View {
    // ゲームオーバー時の遷移を通知するためのクロージャ
    var onGameOver: (() -> Void)?
    @State private var gameScene: GameScene?
    
    var body: some View {
        ZStack {
            if let scene = gameScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            let scene = GameScene(size: UIScreen.main.bounds.size)
            scene.scaleMode = .aspectFill
            // GameScene にクロージャを渡す
            scene.onGameOver = {
                onGameOver?()
            }
            self.gameScene = scene
        }
    }
    
    private func resetGame() {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        self.gameScene = scene
    }
}
