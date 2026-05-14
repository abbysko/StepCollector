//
//  WalkerIcon.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 5/14/26.
//

import SwiftUI

public struct WalkerIcon: View {
    public var size: CGFloat = 40
    /// cornerRadius is now always 25% of size by default
    public var cornerRadius: CGFloat? = nil

    public init(size: CGFloat = 40, cornerRadius: CGFloat? = nil) {
        self.size = size
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        let resolvedCornerRadius = cornerRadius ?? size * 0.25
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.75, green: 0.25, blue: 0.65), Color(red: 0.15, green: 0.15, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "figure.walk")
                .resizable()
                .scaledToFit()
                .padding(size * 0.18)
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 16) {
        WalkerIcon(size: 40)
        WalkerIcon(size: 32)
        WalkerIcon(size: 24)
        WalkerIcon(size: 60)
    }
}
