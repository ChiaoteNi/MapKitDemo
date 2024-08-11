//
//  CommonButtonStyleModifier.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2024/8/11.
//

import SwiftUI

struct CommonButtonStyleModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(radius: 4)
    }
}

extension View {
    func commonButtonStyle() -> some View {
        modifier(CommonButtonStyleModifier())
    }
}
