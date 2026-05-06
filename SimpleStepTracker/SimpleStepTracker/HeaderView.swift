//
//  TabHeaderView.swift
//  SimpleStepTracker
//
//  Created by Abigail Skofield on 4/13/26.
//

import SwiftUI

struct HeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            .padding(.horizontal)
    }
}

#Preview {
    HeaderView(title: "Track Steps")
}
