//
//  GeneralView.swift
//  CursorSync
//
//  Created by Daniel612 on 5/7/25.
//

import SwiftUI

struct GeneralView: View {
    @EnvironmentObject var settings: SettingsModel
    @ObservedObject var viewModel: GeneralViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Current Xcode Version")
                        Spacer()
                        Text("\(settings.xcodeName)")
                        Button("Choose") {
                            viewModel.selectApplication()
                        }
                    }
                    
                    HStack {
                        Text("Open Text Editor")
                        Spacer()
                        if settings.advancedConfig.editorConfigs.isEmpty {
                            Text("No editors configured")
                                .foregroundColor(.gray)
                        } else {
                            Picker("", selection: $settings.selectedEditorConfigID) {
                                ForEach(settings.advancedConfig.editorConfigs) { config in
                                    Text(config.name).tag(config.id as String?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                } footer: {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Apple Script Path: \(viewModel.appleScriptExists ? settings.appleScriptPath : "")")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                if viewModel.appleScriptExists {
                                    Button {
                                        viewModel.revealAppleScriptInFinder()
                                    } label: {
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                    .buttonStyle(.plain) // Use plain style to make it look like an icon button
                                    .foregroundColor(.gray)
                                    .help("Reveal in Finder")
                                }
                            }
                            if settings.remindUpdate && viewModel.appleScriptExists {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Some configurations have changed. Please add the script again.")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            } else {
                                HStack(spacing: 2) {
                                    Image(systemName: viewModel.appleScriptExists ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(viewModel.appleScriptExists ? .green : .red)
                                    Text(viewModel.appleScriptExists ? "Success" : "Not Exist")
                                        .font(.callout)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button("Add") {
                            viewModel.saveAppleScript()
                        }
                    }
                }
                
                Section("Cursor") {
                    Toggle("Include Column", isOn: settings.$includeColumn)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("General")
        }
        .onAppear {
            viewModel.checkAppleScriptStatus() // Check status when view appears
            viewModel.checkScriptVersion()
        }
    }
}

#Preview {
    GeneralView(viewModel: GeneralViewModel(settings: SettingsModel()))
}
