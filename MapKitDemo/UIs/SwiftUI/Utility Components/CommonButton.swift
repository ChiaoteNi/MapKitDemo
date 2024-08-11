//
//  CommonButton.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2024/8/11.
//

import SwiftUI

struct CommonButton: View {

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .font(.headline)
        }
        .frame(height: 30)
        .commonButtonStyle()
    }
}

#Preview {
    CommonButton(title: "YA", action: {})
}
