//
//  AdvancedViewModel.swift
//  CursorSync
//
//  Created by Daniel612 on 5/23/25.
//

import Foundation

class AdvancedViewModel: SettingsViewModel {
    func addEditorConfig(name: String, urlScheme: String) {
        var updatedConfig = settings.advancedConfig // Create a mutable copy
        let newItem = TextEditorConfigItem(id: UUID().uuidString, name: name, urlScheme: urlScheme)
        updatedConfig.editorConfigs.append(newItem)
        settings.advancedConfig = updatedConfig // Reassign to trigger AppStorage write and UI update
        print("[SettingsModel] Added editor config. New count: \(settings.advancedConfig.editorConfigs.count)")
    }

    func deleteEditorConfig(at offsets: IndexSet) {
        var updatedConfig = settings.advancedConfig
        updatedConfig.editorConfigs.remove(atOffsets: offsets)
        settings.advancedConfig = updatedConfig
        print("[SettingsModel] Deleted editor config at offsets. New count: \(settings.advancedConfig.editorConfigs.count)")
        if !settings.advancedConfig.editorConfigs.contains(where: { $0.id == settings.selectedEditorConfigID }) {
            settings.selectedEditorConfigID = settings.advancedConfig.editorConfigs.first?.id ?? "" // Reset to first or empty if selected is deleted
        }
    }

    func deleteEditorConfig(id: String?) {
        guard let idToDelete = id else { return }
        var updatedConfig = settings.advancedConfig
        updatedConfig.editorConfigs.removeAll { $0.id == idToDelete }
        settings.advancedConfig = updatedConfig
        print("[SettingsModel] Deleted editor config by ID. New count: \(settings.advancedConfig.editorConfigs.count)")
        if !settings.advancedConfig.editorConfigs.contains(where: { $0.id == settings.selectedEditorConfigID }) {
            settings.selectedEditorConfigID = settings.advancedConfig.editorConfigs.first?.id ?? "" // Reset to first or empty if selected is deleted
        }
    }
}
