//
//  AdvancedView.swift
//  CursorSync
//
//  Created by Daniel612 on 5/8/25.
//

import SwiftUI
import Foundation

struct AddEditorConfigView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var urlScheme: String = ""
    var onAdd: (String, String) -> Void

    var body: some View {
        VStack {
            Text("Text Editor")
                .font(.headline)
            
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("URL Scheme", text: $urlScheme)
                } footer: {
                    HStack {
                        Spacer()
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .keyboardShortcut(.cancelAction)
                        
                        Button("Add") {
                            if !name.isEmpty && !urlScheme.isEmpty {
                                onAdd(name, urlScheme)
                                dismiss()
                            }
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(name.isEmpty || urlScheme.isEmpty)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .padding()
        .frame(minWidth: 350, idealWidth: 400, minHeight: 200, idealHeight: 220)
    }
}

struct AdvancedView: View {
    @EnvironmentObject private var settings: SettingsModel
    @ObservedObject var viewModel: AdvancedViewModel
    @State private var showingAddSheet = false
    @State private var selectedConfigID: TextEditorConfigItem.ID? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Text Editor") {
                    list
                    bottomBar
                }
            }
            .formStyle(.grouped)
        }
        .navigationTitle("Advanced")
        .sheet(isPresented: $showingAddSheet) {
            AddEditorConfigView { name, urlScheme in
                viewModel.addEditorConfig(name: name, urlScheme: urlScheme)
            }
        }
    }
    
    var list: some View {
        List(selection: $selectedConfigID) {
            if settings.advancedConfig.editorConfigs.isEmpty {
                Text("None")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center) // Center placeholder
            } else {
                ForEach(settings.advancedConfig.editorConfigs) { config in
                    HStack {
                        Text(config.name)
                        Spacer()
                        Text(config.urlScheme)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .tag(config.id) // Important for selection
                }
                // .onDelete(perform: viewModel.deleteConfig) // Alternative swipe-to-delete
            }
        }
        .frame(minHeight: 100, idealHeight: 200, maxHeight: 400) // Constrain list height
    }
    
    var bottomBar: some View {
        HStack(spacing: 8) {
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
            .help("add new url scheme")
            
            Button {
                if let selectedID = selectedConfigID {
                    viewModel.deleteEditorConfig(id: selectedID)
                    selectedConfigID = nil // Deselect after deletion
                }
            } label: {
                Image(systemName: "minus")
            }
            .disabled(selectedConfigID == nil || settings.advancedConfig.editorConfigs.count <= 1)
            .help("delete selected url scheme")
            
            Spacer() // Pushes buttons to the left
        }
        // .padding(.top, 5) // Removed for tighter spacing
    }
}

#Preview {
    AdvancedView(viewModel: AdvancedViewModel(settings: SettingsModel()))
        .frame(width: 450, height: 350) // Provide a reasonable size for preview
}
