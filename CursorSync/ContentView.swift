//
//  ContentView.swift
//  CursorSync
//
//  Created by Daniel612 on 5/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = SettingsModel()
    
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                GeneralView(viewModel: GeneralViewModel(settings: settings))
            }
            Tab("Advanced", systemImage: "gearshape.2.fill") {
                AdvancedView(viewModel: AdvancedViewModel(settings: settings))
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .frame(minWidth: 400, idealWidth: 500, minHeight: 300)
        .environmentObject(settings)
    }
}

#Preview {
    ContentView()
}
