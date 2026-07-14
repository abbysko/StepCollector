//
//  WalkerIcon.swift
//  Step Collector
//
//  Created by Abigail Skofield on 5/14/26.
//

import SwiftUI

public struct WalkerIcon: View {
    public enum Style {
        case rounded
        case circle
    }

    public var size: CGFloat = 40
    public var cornerRadius: CGFloat? = nil
    public var style: Style = .rounded

    public init(size: CGFloat = 40, cornerRadius: CGFloat? = nil, style: Style = .rounded) {
        self.size = size
        self.cornerRadius = cornerRadius
        self.style = style
    }

    public var body: some View {
        let resolvedCornerRadius = cornerRadius ?? size * 0.25
        let symbolPadding = style == .circle ? size * 0.12 : size * 0.18

        ZStack {
            LinearGradient(
                colors: [Color(red: 0.75, green: 0.25, blue: 0.65), Color(red: 0.15, green: 0.15, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "figure.walk")
                .resizable()
                .scaledToFit()
                .padding(symbolPadding)
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .mask {
            if style == .circle {
                Circle()
            } else {
                RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        WalkerIcon(size: 40)
        WalkerIcon(size: 32)
        WalkerIcon(size: 24)
        WalkerIcon(size: 60)
        WalkerIcon(size: 28, style: .circle)
    }
}
