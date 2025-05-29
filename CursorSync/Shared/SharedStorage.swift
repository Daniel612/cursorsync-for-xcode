//
//  AppGroupUserDefaults.swift
//  CursorSync
//
//  Created by Daniel612 on 5/8/25.
//

import Foundation

class SharedStorage {
    static let shared = SharedStorage()
    lazy var userDefaults = {
        guard let userDefaults = UserDefaults(suiteName: "dev.zhangguozheng.CursorSync.shared") else {
            return UserDefaults()
        }
        return userDefaults
    }()
    
    private init() {}
}

extension SharedStorage {
    enum Key {
        static let xcodeName = "xcodeName"
        static let editorConfigs = "editorConfigs"
        static let appleScriptPath = "appleScriptPath"
        static let remindUpdate = "remindUpdate"
        static let includeColumn = "includeColumn"
        static let selectedEditorConfigID = "selectedEditorConfigID"
        static let currentScriptVersion = "currentScriptVersion"
    }
}
