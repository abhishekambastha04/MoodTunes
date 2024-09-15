//
//  PianoAnimationView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 9/14/24.
//

import SwiftUI

struct PianoAnimationView: View {
    @State private var keyPressed = false
    let whiteKeys = 7

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<whiteKeys, id: \.self) { index in
                Rectangle()
                    .fill(keyPressed && index % 2 == 0 ? Color.gray : Color.white)
                    .frame(width: 40, height: 200)
                    .overlay(
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 25, height: 120)
                            .offset(x: index % 2 == 0 ? 20 : -40, y: -40)
                            .opacity(index % 2 == 0 ? 1 : 0)
                    )
                    // Adjust the duration here to slow down the animation
                    .animation(Animation.easeInOut(duration: 1.5).delay(Double(index) * 0.1).repeatForever(autoreverses: true))
            }
        }
        .onAppear {
            keyPressed.toggle()
        }
    }
}
