//
//  GameView.swift
//  PizzaGame
//
//  Created by 堀中　佳樹 on 2024/12/20.
//

import SwiftUI

struct GameView: View {
    // 呼び出し元にゲームオーバーを通知するためのクロージャ
    var onGameOver: ((Int) -> Void)?
    @State private var gameScene: GameScene?
    
    var body: some View {
        ZStack {
            // ゲームシーンを表示
            if let scene = gameScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            // GameScene を生成してonGameOverクロージャをセット
            let scene = GameScene(size: UIScreen.main.bounds.size)
            scene.scaleMode = .aspectFill
            // GameSceneにクロージャを渡す
            scene.onGameOver = { score in
                onGameOver?(score)
            }
            self.gameScene = scene
        }
    }
    
    private func resetGame() {
        // ゲームをリセットして新しいシーンを用意
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        self.gameScene = scene
    }
}
