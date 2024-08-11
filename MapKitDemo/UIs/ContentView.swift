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
                NavigationLink("MapItem ID") {
                    MapItemIdentifierDemoView()
                }
                Spacer()
                NavigationLink("MapItem detail view") {
                    MapItemDetailDemoView()
                }
                Spacer()
            }
            if #available(iOS 17.0, *) {
                NavigationLink("Overlays for the map") {
                    SpotAreaDemoView()
                }
                Spacer()
                NavigationLink("Routes") {
                    RouteDemoView()
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
