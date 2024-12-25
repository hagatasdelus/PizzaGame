//
//  GameView.swift
//  PizzaGame
//
//  Created by 堀中　佳樹 on 2024/12/23.
//

import SwiftUI

struct GameView: View {
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
            self.gameScene = scene
        }
//        .overlay(
//            VStack {
//                Button("New Game") {
//                    resetGame()
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//                .padding(.top, 50)
//                
//                Spacer()
//            }
//        )
    }
    
    private func resetGame() {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        self.gameScene = scene
    }
}
