//
//  SplashView.swift
//  emap-hangzhou
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "map.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                    .scaleEffect(isAnimating ? 1.0 : 0.6)
                    .opacity(opacity)

                Text("吃哪儿")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .opacity(opacity)


            }
        }
        .task {
            withAnimation(.spring(duration: 0.8, bounce: 0.5)) {
                isAnimating = true
            }
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1
            }
        }
    }
}

#Preview {
    SplashView()
}
