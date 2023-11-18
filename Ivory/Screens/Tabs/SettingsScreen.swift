//
//  SettingsScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/12/2022.
//

import SwiftUI
import IvoryCore
import CommonUtils
import DependencyContainer
import Coordinators

struct SettingsScreen: View {
    
    @DI.Observed(DI.settings) private var settings
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Video Quality")
                    Spacer()
                    MenuPicker(selection: $settings.quality, items: Settings.Quality.allCases) {
                        Text($0.description)
                    }
                }
                
                Toggle(isOn: $settings.forceFullscreen) { Text("Always Play Fullscreen") }
                Toggle(isOn: $settings.autoPlayNextVideo) { Text("Autoplay Next Video") }
                Toggle(isOn: $settings.autoStartVideo) { Text("Autostart Video") }
                Toggle(isOn: $settings.backgroundPlayback) { Text("Play in Background") }
                Toggle(isOn: $settings.deleteFromWatchLater) { Text("Delete viewed videos from 'Watch Later'") }
                Toggle(isOn: $settings.hideKidsSpace) { Text("Hide Kids Space") }
                
            } footer: {
                Text("version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)").styled(size: .small)
            }
        }.styled()
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(content: { Color.control.ignoresSafeArea() })
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack { SettingsScreen() }
}
