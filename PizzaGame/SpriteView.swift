//
//  Untitled.swift
//  PizzaGame
//
//  Created by 堀中　佳樹 on 2024/12/23.
//

import SwiftUI
import SpriteKit

struct SpriteView: UIViewRepresentable {
    let scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
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
