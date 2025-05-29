//
//  SourceEditorCommand.swift
//  CursorSyncExtension
//
//  Created by Daniel612 on 5/6/25.
//

import Foundation
import XcodeKit
import AppKit
import Carbon

class CursorySyncCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let settings = SettingsModel()
        let scriptURL = URL(fileURLWithPath: settings.appleScriptPath)
        guard FileManager.default.fileExists(atPath: settings.appleScriptPath) else {
            let error = NSError(domain: "dev.zhangguozheng.cursorsync", code: 1000, userInfo: [NSLocalizedDescriptionKey: "[CursorSync]: Please open CursorSync to add apple script"])
            completionHandler(error)
            return
        }
        let script = try? NSUserAppleScriptTask(url: scriptURL)
        let event = self.eventDescriptior(functionName: "currentFilePath") // Added self.
        script?.execute(withAppleEvent: event, completionHandler: { result, error in
            if let filePath = result?.stringValue {
                print("[CursorySyncCommand] get filePath: \(filePath)")
                // Get selections from invocation buffer
                guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
                    let error = NSError(domain: "dev.zhangguozheng.cursorsync", code: 1001, userInfo: [NSLocalizedDescriptionKey: "[CursorSync]: Could not get text selection from Xcode."])
                    completionHandler(error)
                    return
                }
                
                let line = selection.start.line + 1 // Convert 0-indexed to 1-indexed
                let column = selection.start.column + 1 // Convert 0-indexed to 1-indexed
                
                // Find the selected editor configuration
                guard let editorConfig = settings.advancedConfig.editorConfigs.first(where: { $0.id == settings.selectedEditorConfigID }) else {
                    let error = NSError(domain: "dev.zhangguozheng.cursorsync", code: 1002, userInfo: [NSLocalizedDescriptionKey: "[CursorSync]: Selected editor configuration not found or not set."])
                    completionHandler(error)
                    return
                }
                
                let urlScheme = editorConfig.urlScheme // e.g., "vscode://file/"
                
                // Construct the path with line and column.
                // Example: /Users/username/project/file.swift:10:5
                var pathWithLineAndColumn = "\(filePath):\(line)"
                if settings.includeColumn {
                    pathWithLineAndColumn += ":\(column)"
                }
                
                // Construct the final URL string
                // Example: vscode://file//Users/username/project/file.swift:10:5
                let finalURLString = "\(urlScheme)\(pathWithLineAndColumn)"
                
                guard let urlToOpen = URL(string: finalURLString) else {
                    let error = NSError(domain: "dev.zhangguozheng.cursorsync", code: 1003, userInfo: [NSLocalizedDescriptionKey: "[CursorSync]: Invalid URL constructed: \(finalURLString)"])
                    completionHandler(error)
                    return
                }
                
                // Open the URL
                if NSWorkspace.shared.open(urlToOpen) {
                    completionHandler(nil) // Success
                } else {
                    let error = NSError(domain: "dev.zhangguozheng.cursorsync", code: 1004, userInfo: [NSLocalizedDescriptionKey: "[CursorSync]: Failed to open URL: \(urlToOpen.absoluteString)"])
                    completionHandler(error)
                }
            } else {
                let commonError = NSError(domain: "dev.zhangguozheng.cursorsync", code: 1005, userInfo: [NSLocalizedDescriptionKey: "[CursorSync]: \(error?.localizedDescription ?? "Failed to run apple script")"])
                completionHandler(commonError)
            }
        })
        
        
    }
    
    func eventDescriptior(functionName: String) -> NSAppleEventDescriptor {
        let event = NSAppleEventDescriptor(
            eventClass: UInt32(kASAppleScriptSuite),
            eventID: UInt32(kASSubroutineEvent),
            targetDescriptor: .null(),
            returnID: Int16(kAutoGenerateReturnID),
            transactionID: Int32(kAnyTransactionID)
        )
        let function = NSAppleEventDescriptor(string: functionName)
        event.setDescriptor(function, forKeyword: AEKeyword(keyASSubroutineName))
        return event
    }
    
}
