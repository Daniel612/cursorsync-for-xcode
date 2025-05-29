//
//  GeneralViewModel.swift
//  CursorSync
//
//  Created by Daniel612 on 5/7/25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers
import SwiftUI

class GeneralViewModel: SettingsViewModel {
    @Published var appleScriptExists: Bool = false
    
    override init(settings: SettingsModel) {
        super.init(settings: settings)
        checkAppleScriptStatus()
    }
    
    func selectApplication() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select an Application"
        openPanel.message = "Please select a .app application file." // More detailed prompt
        openPanel.prompt = "Select" // Text on the button
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [UTType.applicationBundle] // Only allow selecting .app files

        // Try to get the /Applications directory, use root as a fallback if it fails
        if let applicationsURL = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask).first {
            openPanel.directoryURL = applicationsURL
        } else {
            // As a fallback, can point to the user's home directory or root, but /Applications usually exists
            openPanel.directoryURL = URL(fileURLWithPath: "/Applications/")
            print("Failed to locate the standard /Applications directory, using /Applications/ as the default path.")
        }

        if openPanel.runModal() == .OK {
            if let selectedURL = openPanel.url {
                // Extract the application name without the .app extension from the URL
                let appName = selectedURL.deletingPathExtension().lastPathComponent
                self.settings.xcodeName = appName
                self.settings.remindUpdate = true
                print("Selected application: \(appName)")
            } else {
                print("Failed to get the URL of the selected application.")
            }
        } else {
            print("User cancelled the select application operation.")
        }
    }
    
    func saveAppleScript() {
        // 1. Get Bundle Identifier (still useful for default path)
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            print("Failed to get Bundle Identifier.")
            return
        }

        // 2. Get Default Application Scripts Directory
        let fileManager = FileManager.default
        var defaultSaveDirectoryURL: URL?
        do {
            defaultSaveDirectoryURL = try fileManager.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathExtension("CursorSyncExtension")
        } catch {
            print("Failed to get default Application Scripts directory: \(error.localizedDescription)")
            // Continue, user can still choose another location even if default directory cannot be obtained
        }

        // 3. Get Script URL from App Bundle
        guard let sourceScriptURL = Bundle.main.url(forResource: "CursorSyncScript", withExtension: "scpt") else {
            print("Error: 'CursorSyncScript.scpt' not found in App Bundle.")
            print("Please ensure the script file is added to your Xcode project and included in the 'Copy Bundle Resources' build phase of the main application target.")
            return
        }

        // 4. Configure and Show NSOpenPanel
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Directory to Save AppleScript"
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Select Directory"
        if let defaultURL = defaultSaveDirectoryURL {
            openPanel.directoryURL = defaultURL // Set default directory to open
        }

        if openPanel.runModal() == .OK {
            guard let selectedDirectoryURL = openPanel.url else {
                print("Failed to get the directory selected by the user.")
                return
            }

            let targetFileURL = selectedDirectoryURL.appendingPathComponent(sourceScriptURL.lastPathComponent)

            // 5. Create Target Directory (if it doesn't exist - NSOpenPanel might create it if canCreateDirectories is true, but good to be safe)
            // No, NSOpenPanel with canCreateDirectories allows user to create, not automatically creates the selected one if it doesn't exist.
            // The selectedDirectoryURL should already exist or be creatable by the user via the panel.
            // We just need to ensure our script can be placed there.

            // 6. Remove existing file at target if it exists (to allow overwrite)
            if fileManager.fileExists(atPath: targetFileURL.path) {
                do {
                    try fileManager.removeItem(at: targetFileURL)
                    // print("Removed existing target file: \(targetFileURL.path)")
                } catch {
                    print("Failed to remove existing target file \(targetFileURL.path): \(error.localizedDescription)")
                    return
                }
            }

            // 7. Read, modify, and write the script file
            do {
                // Read original script content
                var scriptContent = try String(contentsOf: sourceScriptURL, encoding: .utf8)

                // Replace placeholder in script with user-specified application name
                // Important: Ensure your .scpt file contains the placeholder "TARGET_APPLICATION_NAME"
                // Default to "Xcode" if user input is empty or whitespace
                let appNameToUse = settings.xcodeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Xcode" : settings.xcodeName
                scriptContent = scriptContent.replacingOccurrences(of: "TARGET_APPLICATION_NAME", with: appNameToUse)

                // Write modified content to target file
                try scriptContent.write(to: targetFileURL, atomically: true, encoding: .utf8)
                print("Modified AppleScript saved successfully to: \(targetFileURL.path)")
                print("Application name used: \(appNameToUse)") // Add log for debugging
                settings.appleScriptPath = targetFileURL.path
                settings.currentScriptVersion = scriptVersion
                settings.remindUpdate = false
                appleScriptExists = true

            } catch {
                print("Failed to process or save AppleScript to \(targetFileURL.path): \(error.localizedDescription)")
                settings.appleScriptPath = ""
                appleScriptExists = false
            }
        } else {
            print("User cancelled the save operation.")
            // Optionally update status if user cancels and no script was previously set
            // if self.settings.appleScriptPath.isEmpty {
            //     self.settings.appleScriptExists = false
            // }
        }
    }

    func checkAppleScriptStatus() {
        if !settings.appleScriptPath.isEmpty {
            appleScriptExists = FileManager.default.fileExists(atPath: settings.appleScriptPath)
        } else {
            appleScriptExists = false
        }
    }
    
    func checkScriptVersion() {
        if scriptVersion.compare(settings.currentScriptVersion, options: .numeric) == .orderedDescending {
            settings.remindUpdate = true
        } else {
            settings.remindUpdate = false
        }
    }

    func revealAppleScriptInFinder() {
        guard appleScriptExists, !settings.appleScriptPath.isEmpty else {
            print("AppleScript path is not set or file does not exist.")
            return
        }
        let fileURL = URL(fileURLWithPath: settings.appleScriptPath)
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
}
