//
//  NavigationBarHiddenModifier.swift
//  MapKitDemo
//
//  Created by 倪僑德 on 2024/8/11.
//

import SwiftUI

struct NavigationBarHiddenModifier: ViewModifier {
    let isNavigationBarHidden: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbar(
                    isNavigationBarHidden ? .hidden : .visible,
                    for: .navigationBar
                )
        } else {
            content
                .navigationBarHidden(isNavigationBarHidden)
            
        }
    }
}

extension View {
    func hideNavigationBar(_ isNavigationBarHidden: Bool = true) -> some View {
        modifier(NavigationBarHiddenModifier(isNavigationBarHidden: isNavigationBarHidden))
    }
}
