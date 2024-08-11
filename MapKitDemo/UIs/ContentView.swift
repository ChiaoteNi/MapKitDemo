//
//  ContentView.swift
//  MapKitDemo
//
//  Created by 倪僑德 on 2024/8/10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Spacer()
            NavigationLink("UIKit Demo") {
                UIKitDemoView()
                    .edgesIgnoringSafeArea(.all)
            }
            Spacer()
            if #available(iOS 18.0, *) {
                NavigationLink("MapItem detail view & MapItem ID") {
                    MapItemDetailDemoView()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}

// MARK: UIKit

struct UIKitDemoView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MapKitDemoViewController {
        let viewController = MapKitDemoViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: MapKitDemoViewController, context: Context) {
        //...
    }
}
