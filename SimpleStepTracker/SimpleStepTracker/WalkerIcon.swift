//
//  WalkerIcon.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 5/14/26.
//

import SwiftUI

struct WalkerIcon: View {
    var size: CGFloat = 40
    var cornerRadius: CGFloat = 10

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.75, green: 0.25, blue: 0.65), Color(red: 0.15, green: 0.15, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "figure.walk")
                .foregroundStyle(.white)
                .font(.system(size: size * 0.45, weight: .semibold))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: 16) {
        WalkerIcon(size: 40)
        WalkerIcon(size: 32)
        WalkerIcon(size: 24)
    }
}
