//
//  SettingsModel.swift
//  CursorSync
//
//  Created by Daniel612 on 5/9/25.
//

import SwiftUI
import Combine

let scriptVersion = "1.0.2"

class SettingsModel: ObservableObject {
    @CodableStorage(SharedStorage.Key.editorConfigs, store: SharedStorage.shared.userDefaults)
    var advancedConfig: AdvancedConfig = AdvancedConfig()

    @AppStorage(SharedStorage.Key.xcodeName, store: SharedStorage.shared.userDefaults)
    var xcodeName: String = "Xcode"

    @AppStorage(SharedStorage.Key.appleScriptPath, store: SharedStorage.shared.userDefaults)
    var appleScriptPath: String = ""

    @AppStorage(SharedStorage.Key.remindUpdate, store: SharedStorage.shared.userDefaults)
    var remindUpdate: Bool = false
    
    @AppStorage(SharedStorage.Key.currentScriptVersion, store: SharedStorage.shared.userDefaults)
    var currentScriptVersion = ""

    @AppStorage(SharedStorage.Key.includeColumn, store: SharedStorage.shared.userDefaults)
    var includeColumn: Bool = false

    @AppStorage(SharedStorage.Key.selectedEditorConfigID, store: SharedStorage.shared.userDefaults)
    var selectedEditorConfigID: String = ""

    init() {
        checkEditorConfigs()
        checkSelectedEditorConfig()
    }
    
    private func checkEditorConfigs() {
        // Check if editorConfigs is empty and add default values if needed
        if advancedConfig.editorConfigs.isEmpty {
            print("[SettingsModel] No editor configs found, adding default values.")
            var updatedConfig = advancedConfig // Create a mutable copy
            
            let defaultConfigItems = [
                TextEditorConfigItem(id: UUID().uuidString, name: "VSCode", urlScheme: "vscode://file/"),
                TextEditorConfigItem(id: UUID().uuidString, name: "Cursor", urlScheme: "cursor://file/"),
                TextEditorConfigItem(id: UUID().uuidString, name: "Trae-CN", urlScheme: "trae-cn://file/")
            ]
            updatedConfig.editorConfigs.append(contentsOf: defaultConfigItems)
            
            advancedConfig = updatedConfig // Reassign to trigger AppStorage write and UI update
            
            // Optionally, select the first one as default if no editor was previously selected
            if let firstConfig = advancedConfig.editorConfigs.first {
                selectedEditorConfigID = firstConfig.id
                print("[SettingsModel] Set selected editor to the first default: \(firstConfig.name)")
            }
            print("[SettingsModel] Default editor configs added. New count: \(advancedConfig.editorConfigs.count)")
        } else {
            print("[SettingsModel] Existing editor configs found. Count: \(advancedConfig.editorConfigs.count)")
        }
        print("[SettingsModel] Initialized. Final editor configs count: \(advancedConfig.editorConfigs.count)")
    }
    
    private func checkSelectedEditorConfig() {
        // Ensure selectedEditorConfigID is valid or set to the first available
        if advancedConfig.editorConfigs.first(where: { $0.id == selectedEditorConfigID }) == nil {
            selectedEditorConfigID = advancedConfig.editorConfigs.first?.id ?? ""
        }
    }
}

struct AdvancedConfig: Codable {
    var editorConfigs: [TextEditorConfigItem] = []
}

struct TextEditorConfigItem: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var urlScheme: String
}
