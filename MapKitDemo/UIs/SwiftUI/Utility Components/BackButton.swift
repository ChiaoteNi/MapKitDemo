//
//  BackButton.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2024/8/11.
//

import SwiftUI

struct BackButton: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Text("< Back")
                .font(.subheadline)
                .frame(height: 20)
                .commonButtonStyle()
        }
    }
}
