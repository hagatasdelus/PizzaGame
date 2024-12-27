//
//  ContentView.swift
//  PizzaGame
//
//  Created by 堀中　佳樹 on 2024/12/20.
//

import SwiftUI

struct ContentView: View {
    // 画面状態を管理するための enum
    enum ScreenState {
        case title
        case game
        case gameover
    }

    @State private var currentScreen: ScreenState = .title
    @State private var finalScore: Int = 0

    var body: some View {
        // currentScreen の値に応じて表示する画面を切り替える
        switch currentScreen {
        case .title:
            TitleView {
                currentScreen = .game
            }
        case .game:
            GameView { score in
                finalScore = score
                currentScreen = .gameover
            }
        case .gameover:
            GameOverView(score: finalScore) {
                currentScreen = .game
            }
        }
    }
}

// タイトル画面
struct TitleView: View {
    // 開始ボタンが押されたらゲーム画面へ遷移する
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color(red: 38/255, green: 38/255, blue: 38/255).ignoresSafeArea()
            VStack {
                Text("PizzaGame")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                Button("Start") {
                    onStart()
                }
                .font(.title)
                .padding()
                .frame(width: 200, height: 60)
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

// ゲームオーバー画面
struct GameOverView: View {
    let score: Int
    // リスタートボタンが押されたらゲームに戻る
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color(red: 38/255, green: 38/255, blue: 38/255).ignoresSafeArea()
            VStack {
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                Text("Score: \(score)")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                Button("Restart") {
                    onRestart()
                }
                .font(.title)
                .padding()
                .frame(width: 200, height: 60)
                .background(Color.brown)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
