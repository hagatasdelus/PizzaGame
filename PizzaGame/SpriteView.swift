//
//  Untitled.swift
//  PizzaGame
//
//  Created by 堀中　佳樹 on 2024/12/20.
//

import SwiftUI
import SpriteKit

// UIViewRepresentableを使ってSpriteKitのSKViewをSwiftUIで表示
struct SpriteView: UIViewRepresentable {
    // 表示するSKScene
    let scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
        // SKView にシーンを設定し、パフォーマンス用の設定を有効にする
        let view = SKView()
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = true
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
    }
}
