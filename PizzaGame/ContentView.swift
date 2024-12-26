//
//  ContentView.swift
//  PizzaGame
//
//  Created by 堀中　佳樹 on 2024/12/20.
//

import SwiftUI

struct ContentView: View {
    enum ScreenState {
        case title
        case game
        case gameover
    }

    @State private var currentScreen: ScreenState = .title

    var body: some View {
        switch currentScreen {
        case .title:
            TitleView {
                currentScreen = .game
            }
        case .game:
            GameView {
                currentScreen = .gameover
            }
        case .gameover:
            GameOverView {
                currentScreen = .game
            }
        }
    }
}

// タイトル画面
struct TitleView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack {
            Color(red: 38/255, green: 38/255, blue: 38/255).ignoresSafeArea()  // #262626
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
                .background(Color.brown)  // 茶色に変更
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

// ゲームオーバー画面
struct GameOverView: View {
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color(red: 38/255, green: 38/255, blue: 38/255).ignoresSafeArea()
            VStack {
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                Button("Restart") {
                    onRestart()
                }
                .font(.title)
                .padding()
                .frame(width: 200, height: 60)
                .background(Color.brown)  // 茶色に変更
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
